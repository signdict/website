defmodule SignDict.ListEntry do
  use SignDictWeb, :model

  alias SignDict.Entry
  alias SignDict.List
  alias SignDict.ListEntry
  alias SignDict.Repo

  schema "list_entries" do
    field(:sort_order, :integer)
    belongs_to(:list, List)
    belongs_to(:entry, Entry)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:list_id, :entry_id, :sort_order])
    |> add_sort_order_if_needed
    |> validate_required([:list_id, :entry_id, :sort_order])
    |> validate_entry_has_current_video
    |> unique_constraint(:entry_id, name: :list_entries_list_id_entry_id_index)
    |> unique_constraint(:sort_order, name: :list_entries_list_id_sort_order_index)
  end

  defp validate_entry_has_current_video(changeset) do
    entry_id = get_field(changeset, :entry_id)

    entry =
      if !is_nil(entry_id) do
        Repo.get(Entry, entry_id)
      else
        nil
      end

    if is_nil(entry) || is_nil(entry.current_video_id) do
      add_error(changeset, :entry_id, "needs to have a current video attached to it.")
    else
      changeset
    end
  end

  defp add_sort_order_if_needed(changeset) do
    if is_nil(get_field(changeset, :sort_order)) && !is_nil(get_field(changeset, :list_id)) do
      add_sort_order(changeset)
    else
      changeset
    end
  end

  defp add_sort_order(changeset) do
    put_change(changeset, :sort_order, highest_sort_order(changeset) + 1)
  end

  defp highest_sort_order(changeset) do
    list_id = get_field(changeset, :list_id)

    list_item =
      Repo.one(
        from(list_entry in ListEntry,
          where: [list_id: ^list_id],
          order_by: [desc: :sort_order],
          limit: 1
        )
      )

    if list_item do
      list_item.sort_order
    else
      0
    end
  end

  def update_sort_order(entry, sort_order) do
    entry
    |> Ecto.Changeset.change(sort_order: sort_order)
    |> Repo.update()
  end
end
