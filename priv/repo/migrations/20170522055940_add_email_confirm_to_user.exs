defmodule SignDict.Repo.Migrations.AddEmailConfirmToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :unconfirmed_email, :string
      add :confirmation_token, :string
      add :confirmed_at, :utc_datetime
      add :confirmation_sent_at, :utc_datetime
    end
  end
end
