require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @transaction = transactions(:one)
  end

  test "should get index" do
    get transactions_url
    assert_response :success
  end

  test "should get new" do
    get new_transaction_url
    assert_response :success
  end

  test "should create transaction" do
    assert_difference("Transaction.count") do
      post transactions_url, params: { transaction: { buy_price: @transaction.buy_price, buyed_at: @transaction.buyed_at, quantity: @transaction.quantity, sell_price: @transaction.sell_price, selled_at: @transaction.selled_at, status: @transaction.status, ticker: @transaction.ticker } }
    end

    assert_redirected_to transaction_url(Transaction.last)
  end

  test "should show transaction" do
    get transaction_url(@transaction)
    assert_response :success
  end

  test "should get edit" do
    get edit_transaction_url(@transaction)
    assert_response :success
  end

  test "should update transaction" do
    patch transaction_url(@transaction), params: { transaction: { buy_price: @transaction.buy_price, buyed_at: @transaction.buyed_at, quantity: @transaction.quantity, sell_price: @transaction.sell_price, selled_at: @transaction.selled_at, status: @transaction.status, ticker: @transaction.ticker } }
    assert_redirected_to transaction_url(@transaction)
  end

  test "should destroy transaction" do
    assert_difference("Transaction.count", -1) do
      delete transaction_url(@transaction)
    end

    assert_redirected_to transactions_url
  end
end
