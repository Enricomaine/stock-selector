class StockSelectorService
  def call
    data = notification_data

    begin
      Rails.logger.info("[StockSelectorService] Enviando e-mail de notificação. Tickers selecionados: #{data.stock_tickers.size}, transações para realizar: #{data.transactions_not_found.size}, abertas: #{data.open_transactions.size}")
      NotificationMailer.notification(data.stock_tickers, data.transactions_not_found, data.open_transactions).deliver_now
      Rails.logger.info("[StockSelectorService] E-mail de notificação enviado com sucesso")
    rescue StandardError => e
      Rails.logger.error("[StockSelectorService] Falha ao enviar e-mail de notificação: #{e.class} - #{e.message}")
    end

    data.transactions_not_found
  end

  NotificationData = Struct.new(:stock_tickers, :transactions_not_found, :open_transactions, keyword_init: true)

  def notification_data
    Rails.logger.info("[StockSelectorService] Iniciando seleção de ações")

    stocks = ApiConsultant.new.call
    unless stocks
      Rails.logger.error("[StockSelectorService] Nenhum dado retornado da API. E-mail NÃO será enviado.")
      return NotificationData.new(stock_tickers: [], transactions_not_found: [], open_transactions: [])
    end

    first_30 = stocks.select do |stock|
      stock[:p_l] && stock[:liquidezmediadiaria] && stock[:ev_ebit] &&
      stock[:p_l] > 0 && stock[:liquidezmediadiaria] > 500000 && stock[:ev_ebit] > 0
    end

    first_30 = first_30.sort_by { |stock| stock[:ev_ebit] }.first(30)

    open_transactions = Transaction.where(status: 1)

    stock_tickers = first_30.map { |s| s[:ticker] }

    transactions_not_found = open_transactions.reject { |t| stock_tickers.include?(t.ticker) }

    prices_by_ticker = stocks.to_h { |s| [s[:ticker], s[:price]] }

    enriched_transactions_not_found = transactions_not_found.map do |t|
      t.attributes.merge("current_price" => prices_by_ticker[t.ticker])
    end

    enriched_open_transactions = open_transactions.map do |t|
      t.attributes.merge("current_price" => prices_by_ticker[t.ticker])
    end

    NotificationData.new(
      stock_tickers: stock_tickers,
      transactions_not_found: enriched_transactions_not_found,
      open_transactions: enriched_open_transactions
    )
  end
end