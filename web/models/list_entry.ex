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
    |> validate_entry_has_current_video
    |> unique_constraint(:entry_id, name: :list_entries_list_id_entry_id_index)

    # TODO:
    # * Check Sort Order, add it if needed (remove from controller)
  end

  defp validate_entry_has_current_video(changeset) do
    entry_id = get_field(changeset, :entry_id)
    entry = if !is_nil(entry_id) do
      SignDict.Repo.get(SignDict.Entry, entry_id)
    else
      nil
    end
    if is_nil(entry) || is_nil(entry.current_video_id) do
      add_error(changeset, :entry_id, "needs to have a current video attached to it.")
    else
      changeset
    end
  end
end
