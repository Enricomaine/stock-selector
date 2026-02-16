class JobsController < ApplicationController
  # Protege o endpoint com um token secreto
  skip_before_action :verify_authenticity_token

  def run_stock_selector_job
    expected_token = ENV["JOB_TRIGGER_TOKEN"]
    if params[:token] != expected_token
      Rails.logger.warn("[JobsController] Tentativa de acesso com token inválido: #{params[:token]}")
      head :unauthorized
      return
    end

    StockSelectorJob.perform_later
    Rails.logger.info("[JobsController] StockSelectorJob disparado via endpoint externo")
    render plain: "StockSelectorJob triggered"
  end
end
