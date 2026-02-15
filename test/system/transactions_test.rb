require "application_system_test_case"

class TransactionsTest < ApplicationSystemTestCase
  setup do
    @transaction = transactions(:one)
  end

  test "visiting the index" do
    visit transactions_url
    assert_selector "h1", text: "Transactions"
  end

  test "should create transaction" do
    visit transactions_url
    click_on "New transaction"

    fill_in "Buy price", with: @transaction.buy_price
    fill_in "Buyed at", with: @transaction.buyed_at
    fill_in "Quantity", with: @transaction.quantity
    fill_in "Sell price", with: @transaction.sell_price
    fill_in "Selled at", with: @transaction.selled_at
    fill_in "Status", with: @transaction.status
    fill_in "Ticker", with: @transaction.ticker
    click_on "Create Transaction"

    assert_text "Transaction was successfully created"
    click_on "Back"
  end

  test "should update Transaction" do
    visit transaction_url(@transaction)
    click_on "Edit this transaction", match: :first

    fill_in "Buy price", with: @transaction.buy_price
    fill_in "Buyed at", with: @transaction.buyed_at
    fill_in "Quantity", with: @transaction.quantity
    fill_in "Sell price", with: @transaction.sell_price
    fill_in "Selled at", with: @transaction.selled_at
    fill_in "Status", with: @transaction.status
    fill_in "Ticker", with: @transaction.ticker
    click_on "Update Transaction"

    assert_text "Transaction was successfully updated"
    click_on "Back"
  end

  test "should destroy Transaction" do
    visit transaction_url(@transaction)
    click_on "Destroy this transaction", match: :first

    assert_text "Transaction was successfully destroyed"
  end
end
