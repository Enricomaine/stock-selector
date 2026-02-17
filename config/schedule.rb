# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever

set :output, "log/cron.log"
set :environment, ENV['RAILS_ENV'] || 'development'


# Executa uma vez por dia, segunda a sexta, em horário aleatório entre 08 e 14
5.times do
  hour = rand(8..14)
  minute = rand(0..59)
  cron_time = "%02d %02d * * 1-5" % [minute, hour]
  every cron_time do
    runner "StockSelectorJob.perform_later"
  end
end
