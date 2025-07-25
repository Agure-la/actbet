defmodule ActbetWeb.WalletController do
  use ActbetWeb, :controller

  alias Actbet.Accounts.Wallets

  def show(conn, %{"user_id" => user_id}) do
    wallet = Wallets.get_wallet!(user_id)
    json(conn, %{balance: wallet.balance})
  end

  def top_up(conn, %{"user_id" => user_id, "amount" => amount}) do
    case Wallets.top_up_wallet(user_id, Decimal.new(amount)) do
      {:ok, wallet} -> json(conn, %{balance: wallet.balance})
      {:error, reason} -> send_resp(conn, 400, reason)
    end
  end

  def withdraw(conn, %{"user_id" => user_id, "amount" => amount}) do
    case Wallets.withdraw_from_wallet(user_id, Decimal.new(amount)) do
      {:ok, wallet} -> json(conn, %{balance: wallet.balance})
      {:error, reason} -> send_resp(conn, 400, reason)
    end
  end
end
