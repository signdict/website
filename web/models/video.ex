defmodule SignDict.Video do
  use SignDict.Web, :model

  @states [:created, :uploaded, :transcoded, :waiting_for_review, :published, :deleted]

  schema "videos" do
    field :state, :string, default: "created"
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
    |> validate_state()
  end

  def valid_state?(state) when is_atom(state), do: @states |> Enum.member?(state)
  def valid_state?(state), do: valid_state?(String.to_atom(state))

  # Makes sure that the video-state is in the list of possible states.
  defp validate_state(changeset) do
    if changeset && changeset.valid? do
      state = get_field(changeset, :state)

      unless valid_state?(state) do
        error_msg ="must be in the list of " <> Enum.join(@states, ", ")
        add_error(changeset, :state, error_msg)
      else
        changeset
      end
    else
      changeset
    end
  end
end
