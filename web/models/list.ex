defmodule SignDict.List do
  use SignDict.Web, :model

  alias SignDict.Repo
  alias SignDict.ListEntry

  @types ["categorie-list"]
  @sort_orders ["manual", "alphabetical_desc", "alphabetical_asc"]

  schema "lists" do
    field :name, :string
    field :description, :string
    field :type, :string
    field :sort_order, :string
    belongs_to :created_by, SignDict.User
    has_many :list_entries, SignDict.ListEntry
    has_many :entries, through: [:list_entries, :entry]

    timestamps()
  end

  def types, do: @types

  def sort_orders, do: @sort_orders

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def admin_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :type, :sort_order, :description])
    |> validate_required([:name, :type, :sort_order])
    |> validate_inclusion(:type, @types)
    |> validate_inclusion(:sort_order, @sort_orders)
  end

  # TODO:
  # * Paginate list entries
  def entries(%SignDict.List{id: id, sort_order: "manual"}) do
    from(
      list_entry in ListEntry,
      join: entry in assoc(list_entry, :entry),
      where: list_entry.list_id == ^id and not is_nil(entry.current_video_id), order_by: :sort_order
    )
    |> Repo.all
    |> Repo.preload(entry: [:current_video])
  end
  def entries(%SignDict.List{id: id, sort_order: "alphabetical_asc"}) do
    from(
      list_entry in ListEntry,
      join: entry in assoc(list_entry, :entry),
      where: list_entry.list_id == ^id and not is_nil(entry.current_video_id), order_by: entry.text
    )
    |> Repo.all
    |> Repo.preload(entry: [:current_video])
  end
  def entries(%SignDict.List{id: id, sort_order: "alphabetical_desc"}) do
    from(
      list_entry in ListEntry,
      join: entry in assoc(list_entry, :entry),
      where: list_entry.list_id == ^id and not is_nil(entry.current_video_id), order_by: [desc: entry.text]
    )
    |> Repo.all
    |> Repo.preload(entry: [:current_video])
  end

  def remove_entry(list_entry) do
    Repo.delete!(list_entry)

    from(
      u in ListEntry,
      where: u.list_id == ^list_entry.list_id and u.sort_order > ^list_entry.sort_order,
      update: [set: [sort_order: fragment("sort_order - 1")]]
    )
    |> Repo.update_all([])
  end

  def move_entry(list_entry, direction) do
    target_sort_order = list_entry.sort_order + direction
    swap_target = Repo.get_by(ListEntry,
                           list_id: list_entry.list_id,
                           sort_order: target_sort_order)
    swap_list_entry_position(list_entry, swap_target)
  end

  def swap_list_entry_position(list_entry, swap_target) when is_nil(swap_target) do
    list_entry
  end
  def swap_list_entry_position(list_entry, swap_target) do
    ListEntry.update_sort_order(list_entry,  nil)
    ListEntry.update_sort_order(swap_target, list_entry.sort_order)
    ListEntry.update_sort_order(list_entry,  swap_target.sort_order)
    Repo.get(ListEntry, list_entry.id)
  end

end
