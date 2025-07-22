defmodule Actbet.Repo.Migrations.CreateTableBets do
  use Ecto.Migration

  def change do
     create table(:bets) do
      add :user_id, references(:users, on_delete: :delete_all, type: :integer), null: false
      add :game_id, references(:games, on_delete: :delete_all), null: false
      add :bet_choice, :string, null: false  # "home", "away", "draw"
      add :status, :string, null: false, default: "placed"  # placed, cancelled, won, lost
      add :amount, :decimal, null: false
      add :won_amount, :decimal

      timestamps()
    end

    create index(:bets, [:user_id])
    create index(:bets, [:game_id])
    create index(:bets, [:status])
  end
end
