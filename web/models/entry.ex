defmodule SignDict.Entry do
  use SignDict.Web, :model

  alias SignDict.Video
  alias SignDict.Repo
  alias SignDict.Entry

  @types ~w(word phrase example)

  @primary_key {:id, SignDict.Permalink, autogenerate: true}
  schema "entries" do
    field :text, :string
    field :description, :string
    field :type, :string
    belongs_to :language, SignDict.Language

    has_many :videos, Video
    belongs_to :current_video, Video

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:text, :description, :type, :language_id])
    |> validate_required([:text, :description, :type])
    |> validate_inclusion(:type, @types)
    |> foreign_key_constraint(:language_id)
  end

  def with_videos(query) do
    from q in query, preload: :videos
  end

  def with_language(query) do
    from q in query, preload: :language
  end
  def with_current_video(query) do
    from q in query, preload: :current_video
  end

  def types do
    @types
  end

  def to_string(entry) do
    if is_binary(entry.description) && String.trim(entry.description) != "" do
      "#{entry.text} (#{entry.description})"
    else
      entry.text
    end
  end

  def voted_video(entry, user)
  def voted_video(_entry, user) when is_nil(user) do
    %Video{}
  end
  def voted_video(entry, user) do
    query = from(video in Video,
                 inner_join: vote  in SignDict.Vote,
                         on: video.id == vote.video_id,
                 inner_join: entry in SignDict.Entry,
                         on: entry.id == video.entry_id,
                 where: entry.id == ^entry.id and vote.user_id == ^user.id)
    query
    |> Repo.one
    |> Repo.preload(:user)
  end

  def update_current_video(entry) do
    Ecto.Adapters.SQL.query(Repo,
      """
        UPDATE entries SET current_video_id = (
          SELECT videos.id FROM videos LEFT OUTER JOIN votes ON (votes.video_id = videos.id)
            WHERE videos.entry_id = $1::integer AND videos.state = 'published'
            GROUP BY videos.entry_id, videos.id ORDER BY count(votes.id) desc, videos.inserted_at ASC LIMIT 1
        ) WHERE entries.id = $1::integer;
      """, [entry.id]
    )
    Entry
    |> Entry.with_current_video
    |> Repo.get!(entry.id)
  end

  def search(query) do
    query = from(entry in Entry,
            where: ilike(entry.text, ^("%#{query}%")))
    query |> Entry.with_current_video |> Repo.all
  end

end

defimpl Phoenix.Param, for: SignDict.Entry do
  def to_param(%{text: text, id: id}) do
    SignDict.Permalink.to_permalink(id, text)
  end
end
