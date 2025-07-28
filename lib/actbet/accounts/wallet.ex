defmodule Actbet.Accounts.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wallets" do
    field :balance, :decimal, default: 0.0

    belongs_to :user, Actbet.Accounts.User

    timestamps()
  end

  def changeset(wallet, attrs) do
  wallet
  |> cast(attrs, [:balance, :user_id])
  |> validate_required([:user_id, :balance]) 
  |> foreign_key_constraint(:user_id)
end

end
