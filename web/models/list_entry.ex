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
    |> cast(params, [:list_id, :entry_id, :sort_order])
    |> validate_required([:list_id, :entry_id, :sort_order])

    # TODO:
    # * Check Sort Order, add it if needed (remove from controller)
    # * validate that entry has current_video
    # * validate that entry is unique in list
  end
end
