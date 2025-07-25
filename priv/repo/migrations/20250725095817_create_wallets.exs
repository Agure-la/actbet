defmodule Actbet.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
    add :balance, :decimal, default: 0.0, null: false
    add :user_id, references(:users, on_delete: :delete_all), null: false

    timestamps()
  end

  create unique_index(:wallets, [:user_id])
  end
end
