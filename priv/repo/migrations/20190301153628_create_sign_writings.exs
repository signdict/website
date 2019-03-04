defmodule SignDict.Repo.Migrations.CreateSignWritings do
  use Ecto.Migration

  def change do
    create table(:sign_writings) do
      add(:word, :string)
      add(:width, :integer)
      add(:deleges_id, :integer)
      add(:state, :string)
      add(:image, :string)

      add(:entry_id, references(:entries, on_delete: :nothing))

      timestamps()
    end

    create(index(:sign_writings, [:entry_id]))
  end
end
