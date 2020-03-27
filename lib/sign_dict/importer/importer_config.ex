defmodule SignDict.Importer.ImporterConfig do
  use SignDictWeb, :model

  alias SignDict.Repo

  @primary_key {:id, SignDict.Permalink, autogenerate: true}
  schema "importer_configs" do
    field :name, :string
    field :configuration, :map

    timestamps()
  end

  def changeset(importer_config, params \\ %{}) do
    importer_config
    |> cast(params, [:name, :configuration])
    |> validate_required([:name])
  end

  def for(name) do
    Repo.one(from config in __MODULE__, where: config.name == ^name)
  end
end
