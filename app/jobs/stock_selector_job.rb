class StockSelectorJob < ApplicationJob
  queue_as :default

  def perform
    result = StockSelectorService.new.call
    result
  end
end