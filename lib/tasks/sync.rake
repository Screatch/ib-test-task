# frozen_string_literal: true

namespace :fixer do
  # Initial scheduling of tasks
  task resync: :environment do
    initial_date = Calculation::MAX_WEEKS.weeks.ago.to_date
    loop do
      FetchExchangeRateJob.perform_later(initial_date.strftime("%F"))
      break if initial_date == Date.current
      initial_date += 1.day
    end
  end

  # Save file to file system to avoid resyncing since there is rate limiting and it it will take some time
  task save: :environment do
    exchange_rates = []
    ExchangeRate.all.each do |exchange_rate|
      exchange_rates << exchange_rate
    end
    File.open("public/historical_data.json", "w") do |f|
      f.write(events_json.to_json)
    end
  end

  # Import data to exchange_rates table from historical_data.json (previously saved in fixer:save task)
  task import: :environment do
    file = File.open("public/historical_data.json", "rb")
    contents = JSON.parse(file.read)

    ExchangeRate.create(contents)
  end
end
