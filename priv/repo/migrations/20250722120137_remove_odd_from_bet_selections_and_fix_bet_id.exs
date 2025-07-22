defmodule Actbet.Repo.Migrations.RemoveOddFromBetSelectionsAndFixBetId do
  use Ecto.Migration

  def change do
  alter table(:bet_selections) do
      remove :odd
     # modify :bet_id, references(:bets, on_delete: :delete_all), null: false
    end
  end
end
