defmodule Actbet.Repo do
  use Ecto.Repo,
    otp_app: :actbet,
    adapter: Ecto.Adapters.MyXQL
end
