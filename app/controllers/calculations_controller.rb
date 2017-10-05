class CalculationsController < ApplicationController

  def index
    @calculations = Calculation.order(created_at: :desc)
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
            week: historical_data_db.last[:week].to_i,
            year: historical_data_db.last[:year].to_i,
            exchange_rate: historical_data_db.last[:exchange_rate].to_f,
            target_amount: historical_data_db.last[:exchange_rate].to_f * @calculation.base_amount,
            forecast: false,
            profit: 0
        }
    ]

    # Forecast
    forecast_date = Date.current + 7.days
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

    # Rank calculation
    @rate_data = rank_rate_data(@rate_data)


    # Processing fetched data and storing it as instance variable for charting purposes
    @chart_data = get_chart_data(@calculation, historical_data_db, @rate_data)
  end

  def rank_rate_data(rate_data)
    rank = 1
    most_profitable = rate_data.dup.sort_by{|e| [e[:profit]]}.last(3)
    rate_data.map! do |rate_data_item|

      if most_profitable.collect{|item| item[:week]}.include?(rate_data_item[:week]) and
          (most_profitable.collect{|item| item[:year]}.include?(rate_data_item[:year]))

        rate_data_item.merge!({ rank: rank })
        rank += 1
      end

      break if rank > 3
      rate_data_item
    end
    rate_data
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

  def historical_data

  end

  def forecast_data

  end

  def create
    @calculation = current_user.calculations.new(allowed_calculation_params)
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
