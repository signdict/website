defmodule SignDict.ListEntry do
  use SignDict.Web, :model

  schema "list_entries" do
    field :sort_order, :integer
    belongs_to :list, SignDict.List
    belongs_to :entry, SignDict.Entry

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:sort_order])
    |> validate_required([:sort_order])
  end
end
