class Ranking < ApplicationRecord
  def save_ranking(stocks)
    return if Ranking.where(created_at: Time.zone.today.all_day).exists?

    stocks.each_with_index do |stock, index|
      Ranking.create!(ticker: stock[:ticker], position: index + 1)
    end

    Ranking.where("created_at <= ?", 2.days.ago.end_of_day).delete_all
  end
end
