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

  def withdraw_from_wallet(user_id, amount) do
    wallet = get_wallet!(user_id)

    if Decimal.cmp(wallet.balance, amount) == :lt do
      {:error, "Insufficient balance"}
    else
      new_balance = Decimal.sub(wallet.balance, amount)

      wallet
      |> Wallet.changeset(%{balance: new_balance})
      |> Repo.update()
    end
  end
end

