defmodule Actbet.Repo.Migrations.DropForeignKeysFromRolesPermissions do
  use Ecto.Migration

   def up do
    execute("""
    ALTER TABLE roles_permissions
    DROP FOREIGN KEY roles_permissions_role_id_fkey
    """)

    execute("""
    ALTER TABLE roles_permissions
    DROP FOREIGN KEY roles_permissions_permission_id_fkey
    """)
  end

  def down do
    execute("""
    ALTER TABLE roles_permissions
    ADD CONSTRAINT roles_permissions_role_id_fkey
    FOREIGN KEY (role_id) REFERENCES roles(id)
    ON DELETE CASCADE
    """)

    execute("""
    ALTER TABLE roles_permissions
    ADD CONSTRAINT roles_permissions_permission_id_fkey
    FOREIGN KEY (permission_id) REFERENCES permissions(id)
    ON DELETE CASCADE
    """)
  end
end
