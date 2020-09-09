defmodule SignDict.Video do
  use SignDictWeb, :model
  import StateMc.EctoSm
  use Arc.Ecto.Schema

  alias SignDict.Repo
  alias SignDict.Vote

  @states [
    :created,
    :uploaded,
    :prepared,
    :transcoding,
    :waiting_for_review,
    :published,
    :deleted,
    :rejected
  ]

  schema "videos" do
    field :state, :string, default: "created"
    field :copyright, :string
    field :license, :string
    field :original_href, :string
    field :video_url, :string
    field :thumbnail_url, :string
    field :metadata, :map
    field :url, :string, virtual: true

    field :vote_count, :integer, virtual: true

    field :rejection_reason, :string

    field :external_id, :string
    field :auto_publish, :boolean

    field :view_count, :integer, default: 0

    field :sign_writing, SignDictWeb.VideoSignWritingImage.Type

    belongs_to :entry, SignDict.Entry
    belongs_to :user, SignDict.User

    has_many :votes, SignDict.Vote

    timestamps()
  end

  statemc :state do
    defstate(@states)

    defevent(:upload, %{from: [:created], to: :uploaded}, fn changeset ->
      changeset |> Repo.update()
    end)

    defevent(:prepare, %{from: [:uploaded], to: :prepared}, fn changeset ->
      changeset |> Repo.update()
    end)

    defevent(:transcode, %{from: [:uploaded, :prepared], to: :transcoding}, fn changeset ->
      changeset |> Repo.update()
    end)

    defevent(
      :wait_for_review,
      %{from: [:transcoding, :waiting_for_review], to: :waiting_for_review},
      fn changeset ->
        changeset |> Repo.update()
      end
    )

    defevent(
      :publish,
      %{from: [:transcoding, :waiting_for_review, :rejected, :published], to: :published},
      fn changeset ->
        changeset |> Repo.update()
      end
    )

    defevent(:reject, %{from: [:waiting_for_review, :published], to: :rejected}, fn changeset ->
      changeset
      |> validate_rejection_reason
      |> Repo.update()
    end)

    # Allow deletion from every state:
    defevent(
      :delete,
      %{
        from: [
          :created,
          :uploaded,
          :transcoding,
          :waiting_for_review,
          :published,
          :rejected,
          :deleted
        ],
        to: :deleted
      },
      fn changeset ->
        changeset |> Repo.update()
      end
    )
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :state,
      :copyright,
      :license,
      :original_href,
      :user_id,
      :entry_id,
      :video_url,
      :thumbnail_url,
      :metadata,
      :rejection_reason
    ])
    |> validate_required([
      :state,
      :copyright,
      :license,
      :original_href,
      :entry_id,
      :user_id,
      :video_url,
      :thumbnail_url
    ])
    |> foreign_key_constraint(:entry_id)
    |> foreign_key_constraint(:user_id)
    |> cast_attachments(params, [:sign_writing])
    |> validate_state()
  end

  def changeset_uploader(struct, params \\ %{}) do
    struct
    |> cast(params, [:license, :user_id, :entry_id, :metadata, :state])
    |> validate_required([:license, :entry_id, :user_id])
    |> cast_attachments(params, [:sign_writing])
    |> foreign_key_constraint(:entry_id)
    |> foreign_key_constraint(:user_id)
    |> validate_state()
  end

  def changeset_transcoder(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :state,
      :copyright,
      :license,
      :original_href,
      :user_id,
      :entry_id,
      :video_url,
      :thumbnail_url,
      :metadata,
      :auto_publish,
      :external_id
    ])
    |> validate_required([:state, :license, :entry_id, :user_id])
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

  defp validate_rejection_reason(changeset) do
    reason = get_field(changeset, :rejection_reason)

    if is_nil(reason) || String.length(reason) == 0 do
      add_error(changeset, :rejection_reason, "should not be empty")
    else
      changeset
    end
  end

  def ordered_by_vote_for_entry(entry) do
    from(video in SignDict.Video,
      left_join: up in assoc(video, :votes),
      where: video.entry_id == ^entry.id and video.state == ^"published",
      order_by: [desc: count(up.id), asc: video.inserted_at],
      group_by: video.id,
      select: %{video | vote_count: count(up.id)}
    )
  end

  def with_vote_count(video) when not is_nil(video) do
    if video.vote_count == nil && !is_nil(video.id) do
      query = from vote in Vote, where: vote.video_id == ^video.id
      %{video | vote_count: Repo.aggregate(query, :count, :id)}
    else
      video
    end
  end

  def with_vote_count(_video) do
    nil
  end

  def file_path(file) do
    Path.join([
      Application.get_env(:sign_dict, :upload_path),
      "video_upload",
      file
    ])
  end
end
