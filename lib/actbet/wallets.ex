defmodule Actbet.Accounts.Wallets do
  import Ecto.Query, warn: false
  alias Actbet.Repo
  alias Actbet.Accounts.Wallet

  def create_wallet_for_user(user_id) do
    %Wallet{}
    |> Wallet.changeset(%{user_id: user_id})
    |> Repo.insert()
  end

  def get_wallet!(user_id) do
    Repo.get_by!(Wallet, user_id: user_id)
  end

  def top_up_wallet(user_id, amount) do
    wallet = get_wallet!(user_id)
    new_balance = Decimal.add(wallet.balance, amount)

    wallet
    |> Wallet.changeset(%{balance: new_balance})
    |> Repo.update()
  end

  defp send_to_msisdn(msisdn, amount) do
  IO.puts("Sending KES #{Decimal.to_string(amount)} to #{msisdn}")
  :ok
end

 def withdraw_from_wallet(user_id, amount) do
  fee = Decimal.new("23.00")
  total_deduction = Decimal.add(amount, fee)
  betting_account_id = 1

  Repo.transaction(fn ->
    user_wallet = get_wallet!(user_id)

    if Decimal.cmp(user_wallet.balance, total_deduction) == :lt do
      Repo.rollback("Insufficient balance. Total needed: #{Decimal.to_string(total_deduction)}")
    end

    new_user_balance = Decimal.sub(user_wallet.balance, total_deduction)
    user_wallet
    |> Wallet.changeset(%{balance: new_user_balance})
    |> Repo.update!()

    # Add fee to betting account
    betting_wallet = get_wallet!(betting_account_id)
    new_betting_balance = Decimal.add(betting_wallet.balance, fee)

    betting_wallet
    |> Wallet.changeset(%{balance: new_betting_balance})
    |> Repo.update!()

    user = Actbet.Accounts.get_user!(user_id)
    send_to_msisdn(user.msisdn, amount)
    get_wallet!(user_id)
  end)
end

end
