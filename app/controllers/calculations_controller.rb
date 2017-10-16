# frozen_string_literal: true

class CalculationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @calculations = current_user.calculations.order(created_at: :desc)
  end

  def new
    @calculation = Calculation.new
  end

  def edit
    @calculation = current_user.calculations.find(params[:id])
  end

  def update
    @calculation = current_user.calculations.find(params[:id])
    @calculation.assign_attributes(allowed_calculation_params)

    if @calculation.save
      flash[:notice] = "Calculation was succesfully updated"
      redirect_to @calculation
    else
      render :new
    end
  end

  def create
    @calculation = current_user.calculations.new(allowed_calculation_params)

    if @calculation.save
      flash[:notice] = "Calculation was succesfully created"
      redirect_to @calculation
    else
      render :new
    end
  end

  def destroy
    @calculation = current_user.calculations.find(params[:id])

    redirect_to calculations_path if @calculation.destroy
  end

  def show
    @calculation = current_user.calculations.find(params[:id])

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

    forecast_data = HoltWinters.forecast(historical_data_db.collect { |rate| rate[:exchange_rate].to_f * @calculation.base_amount }, 0, 1, 0, 5, 4).reject { |item| item == 0 }
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
    @top_profit_item = @rate_data.select { |rate_data_item| rate_data_item[:rank] == 1 }.first

    # Processing fetched data and storing it as instance variable for charting purposes
    @chart_data = get_chart_data(@calculation, historical_data_db, @rate_data)
  end

  def rank_rate_data(rate_data)
    rank = 1
    most_profitable = rate_data.dup.sort_by { |e| [e[:profit]] }.reverse.first(3)

    while rank <= 3
      rate_data.each do |value|
        next unless value[:week] == most_profitable[rank - 1][:week]
        value[:rank] = rank
        rank += 1
        break
      end
    end

    rate_data
  end

  def get_chart_data(calculation, historical_data, forecast_data)
    chart_data = {}

    %w(historical forecast).each do |key|
      weeks = []
      amount = []

      binding.local_variable_get("#{key}_data").each do |rate_row|
        weeks << "W#{rate_row[:week]} #{rate_row[:year]}"
        amount << (rate_row[:exchange_rate].to_f * calculation.base_amount).round(3)
      end

      chart_data[key.to_sym] = { weeks: weeks, amount: amount }
    end

    chart_data
  end

  private

    def allowed_calculation_params
      params.require(:calculation).permit(:base_currency, :target_currency, :base_amount, :wait_until, :weeks_to_wait)
    end

    def build_rates_query(calculation, days_between_dates)
      ExchangeRate.select("
date_part('year', created_at::date)::numeric as year,
date_part('week', created_at::date)::numeric as week,
COALESCE(avg((rate_data->>'#{calculation.target_currency}')::numeric),1)/COALESCE(avg((rate_data->>'#{calculation.base_currency}')::numeric),1) AS exchange_rate")
                       .where(created_at: (Date.current - days_between_dates.days)..calculation.created_at.to_date)
                       .group(:year, :week).sort_by { |e| [e.week, e.year] }
    end
end
