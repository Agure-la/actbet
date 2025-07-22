
alias Actbet.Accounts
alias Actbet.Accounts.Role

Enum.each(["frontend", "admin", "superuser"], fn role_name ->
  Accounts.get_role_by_name(role_name) ||
    Accounts.create_role(%{name: role_name})
end)
