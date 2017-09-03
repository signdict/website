defmodule SignDict.List do
  use SignDict.Web, :model

  @types ["categorie-list"]
  @sort_orders ["manual", "alphabetical_desc", "alphabetical_asc"]

  schema "lists" do
    field :name, :string
    field :description, :string
    field :type, :string
    field :sort_order, :string
    belongs_to :created_by, SignDict.User

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
end
