defmodule Actbet.Repo do
  use Ecto.Repo,
    otp_app: :actbet,
    adapter: Ecto.Adapters.MyXQL

    use Scrivener, page_size: 10
end
