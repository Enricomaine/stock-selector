class NotificationMailer < ApplicationMailer
  def notification(stocks, transactions_not_found, open_transactions)
    @stocks = stocks
    @transactions = transactions_not_found
    @open_transactions = open_transactions
    mail(
      to: "enricomaine@gmail.com",
      subject: "Atualizações do evaluation"
    )
  end
end
