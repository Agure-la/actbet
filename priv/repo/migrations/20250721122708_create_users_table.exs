defmodule Actbet.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
     create table(:users, primary_key: true) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email_address, :string, null: false
      add :msisdn, :string, null: false
      add :password, :string
      add :password_hash, :string
      #add :user_id, :binary_id, null: false

      timestamps()
    end
  end
end
