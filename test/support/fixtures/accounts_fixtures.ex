defmodule Actbet.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Actbet.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        \: "some \\"
      })
      |> Actbet.Accounts.create_user()

    user
  end
end
