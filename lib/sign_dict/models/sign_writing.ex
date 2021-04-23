defmodule SignDict.SignWriting do
  use SignDictWeb, :model
  use Arc.Ecto.Schema
  import StateMc.EctoSm

  alias SignDict.Repo

  @states [:active, :marked_as_wrong, :wrong]

  schema "sign_writings" do
    field(:word, :string)
    field(:width, :integer)
    field(:deleges_id, :integer)
    field(:state, :string, default: "active")
    field(:image, SignDictWeb.SignWritingImage.Type)

    belongs_to(:entry, SignDict.Entry)
    timestamps()
  end

  statemc :state do
    defstate(@states)

    defevent(:mark_as_wrong, %{from: [:active], to: :marked_as_wrong}, fn changeset ->
      changeset |> Repo.update()
    end)

    defevent(:wrong, %{from: [:mark_as_wrong], to: :wrong}, fn changeset ->
      changeset |> Repo.update()
    end)

    defevent(:correct, %{from: [:mark_as_wrong], to: :active}, fn changeset ->
      changeset |> Repo.update()
    end)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :word,
      :width,
      :deleges_id,
      :entry_id,
      :state
    ])
    |> cast_attachments(params, [:image])
    |> validate_required([
      :word,
      :width,
      :deleges_id,
      :entry_id
    ])
    |> foreign_key_constraint(:entry_id)
    |> validate_state()
  end

  def valid_state?(state) when is_atom(state), do: @states |> Enum.member?(state)
  def valid_state?(state), do: valid_state?(String.to_atom(state))

  # Makes sure that the video-state is in the list of possible states.
  defp validate_state(changeset) do
    if changeset.valid? do
      state = get_field(changeset, :state)

      if valid_state?(state) do
        changeset
      else
        error_msg = "must be in the list of " <> Enum.join(@states, ", ")
        add_error(changeset, :state, error_msg)
      end
    else
      changeset
    end
  end
end
