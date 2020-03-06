defmodule SignDict.Domain do
  use SignDictWeb, :model

  alias SignDict.Domain
  alias SignDict.Entry
  alias SignDict.Repo

  @primary_key {:id, SignDict.Permalink, autogenerate: true}
  schema "domains" do
    field(:domain, :string)

    many_to_many(:entries, Entry, join_through: "domains_entries")

    timestamps()
  end

  def for(domain) do
    Repo.one!(from d in Domain, where: d.domain == ^domain)
  end
end
