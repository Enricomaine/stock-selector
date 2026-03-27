class StockSelectorService
  MIN_LIQUIDITY    = 500_000
  TOP_STOCKS_LIMIT = 30
  CATEGORY_TYPES   = [ 1, 12 ].freeze

  Result = Struct.new(
    :stock_tickers,
    :transactions_not_found,
    :open_transactions,
    keyword_init: true
  )

  def call
    build_result
  end

  private

  def build_result
    Rails.logger.info(log_prefix + "Iniciando seleção de ações")

    stocks = fetch_stocks
    return empty_result if stocks.blank?

    filtered_stocks = filter_stocks(stocks)
    top_stocks_by_category = CATEGORY_TYPES.to_h do |category_type|
      stocks_for_category = filtered_stocks.select { |s| s[:category_type].to_i == category_type }
      [ category_type, select_top_stocks(stocks_for_category) ]
    end
    top_stocks = top_stocks_by_category.values.flatten

    open_transactions = fetch_open_transactions
    tickers_set       = extract_tickers(top_stocks)

    transactions_not_found = find_missing_transactions(open_transactions, tickers_set)
    prices_by_ticker       = map_prices(stocks)

    result = Result.new(
      stock_tickers: tickers_set.to_a,
      transactions_not_found: enrich_transactions(transactions_not_found, prices_by_ticker),
      open_transactions: enrich_transactions(open_transactions, prices_by_ticker)
    )

    ranking = Ranking.new
    top_stocks_by_category.each do |category_type, stocks_for_category|
      ranking.save_ranking(stocks_for_category, category_type)
    end

    Rails.logger.info(summary_log(result))
    result
  end

  def fetch_stocks
    ApiConsultant.new.call
  rescue StandardError => e
    Rails.logger.error(log_prefix + "Erro ao consultar API: #{e.class} - #{e.message}")
    nil
  end

  def fetch_open_transactions
    Transaction.open
  end

  def filter_stocks(stocks)
    stocks.select do |s|
      p_l = s[:p_l].to_f
      ev_ebit = s[:ev_ebit].to_f

      next false unless p_l > 0 && ev_ebit > 0

      category_type = s[:category_type].to_i

      next true if category_type == 12

      s[:liquidezmediadiaria].to_f > MIN_LIQUIDITY
    end
  end

  def select_top_stocks(stocks)
    stocks.min_by(TOP_STOCKS_LIMIT) { |s| s[:ev_ebit] }
  end

  def extract_tickers(stocks)
    stocks.map { |s| s[:ticker] }.to_set
  end

  def map_prices(stocks)
    stocks.to_h { |s| [ s[:ticker], s[:price] ] }
  end

  def find_missing_transactions(open_transactions, tickers_set)
    open_transactions.reject do |t|
      tickers_set.include?(t.ticker)
    end
  end

  def enrich_transactions(transactions, prices_by_ticker)
    transactions.map do |t|
      {
        id: t.id,
        ticker: t.ticker,
        current_price: prices_by_ticker[t.ticker]
      }
    end
  end

  def empty_result
    Rails.logger.warn(log_prefix + "Nenhum dado retornado da API")

    Result.new(
      stock_tickers: [],
      transactions_not_found: [],
      open_transactions: []
    )
  end

  def log_prefix
    "[StockSelectorService] "
  end

  def summary_log(result)
    log_prefix +
      "Processamento concluído. " \
      "Tickers: #{result.stock_tickers.size}, " \
      "Não encontradas: #{result.transactions_not_found.size}, " \
      "Abertas: #{result.open_transactions.size}"
  end
end
