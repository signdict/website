defmodule SignDict.Video do
  use SignDict.Web, :model
  import StateMc.EctoSm

  alias SignDict.Repo

  @states [:created, :uploaded, :transcoded, :waiting_for_review,
           :published, :deleted]

  schema "videos" do
    field :state, :string, default: "created"
    field :copyright, :string
    field :license, :string
    field :original_href, :string
    field :video_url, :string
    field :thumbnail_url, :string
    field :plays, :integer

    belongs_to :entry, SignDict.Entry
    belongs_to :user, SignDict.User

    has_many :votes, SignDict.Vote

    timestamps()
  end

  statemc :state do
    defstate @states

    defevent :upload, %{from: [:created], to: :uploaded}, fn (changeset) ->
      changeset |> Repo.update() # TODO: actually upload the file
    end

    defevent :transcode, %{from: [:uploaded], to: :transcoded}, fn(changeset) ->
      changeset |> Repo.update()
    end

    defevent :wait_for_review, %{from: [:transcoded],
                                 to: :waiting_for_review}, fn(changeset) ->
      changeset |> Repo.update()
    end

    defevent :publish, %{from: [:waiting_for_review],
                         to: :published}, fn(changeset) ->
      changeset |> Repo.update()
    end

    # Allow deletion from every state:
    defevent :delete, %{from: [:created, :uploaded, :transcoded,
                               :waiting_for_review, :published],
                        to: :deleted}, fn(changeset) ->
      changeset |> Repo.update()
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:state, :copyright, :license, :original_href,
                     :user_id, :entry_id, :video_url, :thumbnail_url, :plays])
    |> validate_required([:state, :copyright, :license, :original_href,
                          :entry_id, :user_id, :video_url, :thumbnail_url])
    |> foreign_key_constraint(:entry_id)
    |> foreign_key_constraint(:user_id)
    |> validate_state()
  end

  def valid_state?(state) when is_atom(state), do: @states |> Enum.member?(state)
  def valid_state?(state), do: valid_state?(String.to_atom(state))

  # Makes sure that the video-state is in the list of possible states.
  defp validate_state(changeset) do
    if changeset && changeset.valid? do
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

  def ordered_by_vote_for_entry(entry) do
    from(video in SignDict.Video,
      left_join: up in assoc(video, :votes),
      where: video.entry_id == ^entry.id,
      order_by: [desc: count(up.id), desc: video.inserted_at],
      group_by: video.id,
      select: video)
  end

end
