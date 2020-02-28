defmodule SignDict.Domain do
  use SignDictWeb, :model

  alias SignDict.Entry

  @primary_key {:id, SignDict.Permalink, autogenerate: true}
  schema "domains" do
    field(:domain, :string)

    many_to_many(:entries, Entry, join_through: "domains_entries")

    timestamps()
  end
end
