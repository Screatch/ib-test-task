class CalculationsController < ApplicationController

  def index
    @calculations = Calculation.all
  end

  def new
    @calculation = Calculation.new
  end


  def show
    @calculation = Calculation.find(params[:id])

    days_between_dates = (@calculation.created_at.to_date..@calculation.wait_until).count
    historical_data_db = build_rates_query(@calculation, days_between_dates)

    # Push the last rate for the current week to array

    @rate_data = [
        {
            week: historical_data_db.last[:week],
            year: historical_data_db.last[:year],
            exchange_rate: historical_data_db.last[:exchange_rate],
            target_amount: historical_data_db.last[:exchange_rate].to_f * @calculation.base_amount,
            forecast: false,
            profit: 0
        }
    ]

    # Forecast
    forecast_date = Date.current + 7.days

    # raise historical_data_db.collect{|rate| rate[:exchange_rate].to_f * @calculation.base_amount }.inspect
    forecast_data = HoltWinters.forecast(historical_data_db.collect{|rate| rate[:exchange_rate].to_f * @calculation.base_amount }, 0.5, 0, 0, 2, 2).reject{|item| item == 0}

    forecast_data.each do |forecast_rate|

      @rate_data << {
          week: forecast_date.strftime("%W").to_i,
          year: forecast_date.strftime("%Y").to_i,
          exchange_rate: forecast_rate / @calculation.base_amount,
          target_amount: forecast_rate,
          forecast: true,
          profit: forecast_rate - @rate_data.first[:target_amount]
      }

      forecast_date += 7.days
    end

    # Processing fetched data and storing it as instance variable for charting purposes
    @chart_data = get_chart_data(@calculation, historical_data_db, @rate_data)
  end

  def get_chart_data(calculation, historical_data, forecast_data)

    chart_data = {}

    ['historical', 'forecast'].each do |key|
      weeks = []
      amount = []

      binding.local_variable_get("#{key}_data").each do |rate_row|
        weeks << "W#{rate_row[:week]} #{rate_row[:year]}"
        amount << (rate_row[:exchange_rate].to_f * calculation.base_amount)
      end

      chart_data[key.to_sym] = { weeks: weeks, amount: amount }
    end

    chart_data
  end




  # def show
  #   @calculation = Calculation.find(params[:id])
  #
  #   days_between_dates = (@calculation.created_at.to_date..@calculation.wait_until).count
  #   rate_data_db = build_rates_query(@calculation, days_between_dates)
  #
  #   @rate_data = []
  #
  #   @target_amount_array = []
  #   @weeks_array = []
  #
  #   # Historical data
  #   rate_data_db.each do |rate_row|
  #
  #     # Charts
  #     @weeks_array << "W#{rate_row['week']} #{rate_row['year']}"
  #     @target_amount_array << rate_row['exchange_rate'].to_f * @calculation.base_amount
  #
  #     @rate_data << {
  #         week: rate_row['week'],
  #         year: rate_row['year'],
  #         exchange_rate: rate_row['exchange_rate'],
  #         target_amount: rate_row['exchange_rate'].to_f * @calculation.base_amount,
  #         forecast: false
  #     }
  #   end
  #
  #   # Forecast
  #   forecast_date = Date.current + 7.days
  #   forecast_data = TeaLeaves.forecast(@rate_data.collect{|rate| rate[:target_amount]}, 9, days_between_dates)
  #
  #   chart_data = get_chart_data(@rate_data)
  #
  #   forecast_data.each do |forecast_rate|
  #
  #     @rate_data << {
  #         week: forecast_date.strftime("%W").to_i,
  #         year: forecast_date.strftime("%Y").to_i,
  #         exchange_rate: forecast_rate,
  #         target_amount: forecast_rate * @calculation.base_amount,
  #         forecast: true
  #     }
  #
  #     forecast_date += 7.days
  #   end
  # end

  def historical_data

  end

  def forecast_data

  end

  def create
    @calculation = Calculation.new(allowed_calculation_params)
    @calculation.wait_until = Date.current + params[:calculation][:wait_until].to_i.weeks

    if @calculation.save
      redirect_to @calculation
    else
      render :new
    end
  end

  private

  def allowed_calculation_params
    params.require(:calculation).permit(:base_currency, :target_currency, :base_amount)
  end

  def build_rates_query(calculation, days_between_dates)
    raw_result = ActiveRecord::Base.connection.execute("
SELECT
date_part('year', created_at::date)::numeric as year,
date_part('week', created_at::date)::numeric as week,
COALESCE(avg((rate_data->>'#{calculation.target_currency}')::numeric),1)/COALESCE(avg((rate_data->>'#{calculation.base_currency}')::numeric),1) AS exchange_rate
FROM exchange_rates
WHERE created_at >= '#{(Date.current - days_between_dates.days).to_formatted_s(:db)}' AND created_at <= '#{calculation.created_at.to_date.to_formatted_s(:db)}'
GROUP BY year, week
")

    # Symbolize keys to symbols and sort by week and year
    raw_result.inject([]){|res, val| res << val.symbolize_keys}.sort_by{|e| [e[:week], e[:year]]}
  end

  def prepare_data

  end

end
