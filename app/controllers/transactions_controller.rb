class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[show edit update destroy]

  # GET /transactions
  def index
    @open_transactions   = Transaction.open
    @closed_transactions = Transaction.closed.order(selled_at: :desc).page(params[:page]).per(10)

    current_month_range = Time.zone.now.beginning_of_month..Time.zone.now.end_of_month

    @monthly_sold_total = Transaction.closed
                                     .where(selled_at: current_month_range)
                                     .sum("sell_price * quantity")
  end

  def stock_analysis
    result = StockSelectorService.new.call

    if empty_result?(result)
      redirect_to transactions_path, alert: "Não foi possível obter os dados." and return
    end

    @stocks_type_1     = Ranking.current_with_position_diff(1)
    @stocks_type_12    = Ranking.current_with_position_diff(12)
    @transactions      = result.transactions_not_found
    @open_transactions = result.open_transactions
  end

  # GET /transactions/1
  def show; end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
  end

  # GET /transactions/1/edit
  def edit
    current_month_range = Time.zone.now.beginning_of_month..Time.zone.now.end_of_month

    @monthly_sold_total = Transaction.closed
                                     .where(selled_at: current_month_range)
                                     .where.not(id: @transaction.id)
                                     .sum("sell_price * quantity")

    @target_value = 20_000.0
  end

  # POST /transactions
  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.status   = 1
    @transaction.buyed_at = Time.zone.now

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to @transaction, notice: "Transaction criada com sucesso." }
        format.json { render :show, status: :created, location: @transaction }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transactions/1
  def update
    respond_to do |format|
      if @transaction.update(transaction_params.merge(status: 2, selled_at: Time.zone.now))
        format.html { redirect_to @transaction, notice: "Transaction atualizada com sucesso.", status: :see_other }
        format.json { render :show, status: :ok, location: @transaction }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1
  def destroy
    @transaction.destroy!

    respond_to do |format|
      format.html { redirect_to transactions_path, notice: "Transaction removida com sucesso.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_transaction
    @transaction = Transaction.find(params.expect(:id))
  end

  def transaction_params
    if action_name == "update"
      params.require(:transaction).permit(:sell_price)
    else
      params.require(:transaction).permit(:ticker, :buy_price, :quantity)
    end
  end

  def empty_result?(result)
    result.stock_tickers.empty? &&
      result.transactions_not_found.empty? &&
      result.open_transactions.empty?
  end
end
