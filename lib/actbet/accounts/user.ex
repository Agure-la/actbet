defmodule Actbet.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
@derive {Jason.Encoder, only: [:id, :email_address, :first_name, :last_name, :msisdn, :role_id]}

schema "users" do
  field :first_name, :string
  field :last_name, :string
  field :email_address, :string
  field :msisdn, :string
  field :password, :string
  field :password_hash, :string
  belongs_to :role, Actbet.Accounts.Role
 # field :user_id, Ecto.UUID, autogenerate: true
  timestamps()
end

@doc false
def changeset(user, attrs) do
  user
  |> cast(attrs, [:first_name, :last_name, :email_address, :msisdn, :password, :role_id])
  |> validate_required([:first_name, :last_name, :email_address, :msisdn,:password, :role_id])
  |> unique_constraint(:email_address)
  |> unique_constraint(:msisdn)
 # |> put_password_hash()
  #|> put_change(:user_id, Ecto.UUID.generate())
end

@doc false
 def registration_changeset(user, attrs) do
  user
  |> cast(attrs, [:first_name, :last_name, :email_address, :msisdn, :password, :role_id])
  |> validate_required([:first_name, :last_name, :email_address, :msisdn, :password, :role_id])
  |> unique_constraint(:email_address)
  |> unique_constraint(:msisdn)
  #|> put_user_id()
end

 # defp put_password_hash(changeset) do
  #  case get_change(changeset, :password) do
   #   nil -> changeset
    #  password -> put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    #end
  #end

  defp put_user_id(changeset) do
    put_change(changeset, :user_id, Ecto.UUID.generate())
  end
end
