defmodule SignDict.Video do
  use SignDict.Web, :model

  schema "videos" do
    field :state, :string
    field :copyright, :string
    field :license, :string
    field :original_href, :string
    field :type, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:state, :copyright, :license, :original_href, :type])
    |> validate_required([:state, :copyright, :license, :original_href, :type])
  end
end
