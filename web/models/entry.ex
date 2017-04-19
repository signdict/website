defmodule SignDict.Entry do
  use SignDict.Web, :model

  alias SignDict.Video

  @types ~w(word phrase example)

  @primary_key {:id, SignDict.Permalink, autogenerate: true}
  schema "entries" do
    field :text, :string
    field :description, :string
    field :type, :string
    belongs_to :language, SignDict.Language
    has_many :videos, Video

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
                 inner_join: vote  in SignDict.Vote,  on: video.id == vote.video_id,
                 inner_join: entry in SignDict.Entry, on: entry.id == video.entry_id,
                 where: entry.id == ^entry.id and vote.user_id == ^user.id)
    query
    |> SignDict.Repo.one
    |> SignDict.Repo.preload(:user)
  end

end

defimpl Phoenix.Param, for: SignDict.Entry do
  def to_param(%{text: text, id: id}) do
    SignDict.Permalink.to_permalink(id, text)
  end
end
