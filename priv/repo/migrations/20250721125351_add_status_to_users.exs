defmodule Actbet.Repo.Migrations.AddStatusToUsers do
  use Ecto.Migration

  def change do
        alter table(:users) do
      add :status, :integer, default: 0, null: false
    end

  end
end
