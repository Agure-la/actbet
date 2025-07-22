defmodule Actbet.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Actbet.Repo

  alias Actbet.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  def get_role_by_name(name) do
  Repo.get_by(Actbet.Accounts.Role, name: name)
end

  def register_user(attrs) do
  case get_user_by_email_or_msisdn(attrs["email_address"], attrs["msisdn"]) do
    nil ->
      case get_role_by_name("frontend") do
        nil ->
          {:error, "Default role not found. Please seed roles properly."}

        %Actbet.Accounts.Role{id: role_id} ->
          updated_attrs = Map.put(attrs, "role_id", role_id)

          %User{}
          |> User.registration_changeset(updated_attrs)
          |> Repo.insert()
      end

    _ ->
      {:error, "User already exists with this email or MSISDN"}
  end
end


  def verify_and_get_user(token) do
  # Decode and verify token (adjust based on your token logic)
  case Phoenix.Token.verify(ActbetWeb.Endpoint, "user_auth", token, max_age: 86400) do
    {:ok, user_id} ->
      case Repo.get(Actbet.Accounts.User, user_id) do
        nil -> {:error, :not_found}
        user -> {:ok, user}
      end

    {:error, _} ->
      {:error, :invalid_token}
  end
end

  def login_user(msisdn, given_password) do
    case get_user_by_msisdn(msisdn) do
      nil ->
        {:error, "User not registered"}

      user ->
        if user.password == given_password do
          {:ok, user}
        else
          {:error, "Invalid password"}
        end
    end
  end

 def get_user_by_msisdn(msisdn) do
    Repo.one(from u in User, where: u.msisdn == ^msisdn)
  end

#def get_role_by_name(name), do: Repo.get_by(Role, name: name)
def create_role(attrs) do
  %Actbet.Accounts.Role{}
  |> Actbet.Accounts.Role.changeset(attrs)
  |> Repo.insert()
end


  defp get_user_by_email_or_msisdn(email, msisdn) do
    Repo.one(from u in User, where: u.email_address == ^email or u.msisdn == ^msisdn)
  end
  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def list_users_with_bets do
    from(u in User,
      where: is_nil(u.deleted_at),
      preload: [:bets]
    )
    |> Repo.all()
  end

  def total_profit_from_losses do
    from(b in Bet, where: b.status == "lost", select: sum(b.amount))
    |> Repo.one()
  end

  def update_user_role(user_id, new_role_name) do
  role = Repo.get_by!(Actbet.Accounts.Role, name: new_role_name)
  user = Repo.get!(Actbet.Accounts.User, user_id)

  user
  |> Ecto.Changeset.change(role_id: role.id)
  |> Repo.update()
end

def soft_delete_user(user_id) do
  Repo.transaction(fn ->
    user = Repo.get!(User, user_id)

    user =
      user
      |> Ecto.Changeset.change(deleted_at: DateTime.utc_now())
      |> Repo.update!()

    from(b in Bet, where: b.user_id == ^user.id)
    |> Repo.update_all(set: [status: 0])
  end)
end

end
