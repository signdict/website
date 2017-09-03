defmodule SignDict.Entry do
  use SignDict.Web, :model

  alias SignDict.Video
  alias SignDict.Repo
  alias SignDict.Entry
  alias Ecto.Adapters.SQL
  alias SignDict.PostgresQueryHelper

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
    |> trim_fields
    |> unique_constraint(:text, name: :entries_text_description_index)
    |> validate_required([:text, :type, :language_id])
    |> validate_inclusion(:type, @types)
    |> foreign_key_constraint(:language_id)
  end

  def find_by_changeset(changeset) do
    if changeset.valid? do
      Repo.get_by(
        SignDict.Entry,
        text:        get_field(changeset, :text) || "",
        description: get_field(changeset, :description) || "",
        language_id: get_field(changeset, :language_id),
        type:        get_field(changeset, :type)
      )
    else
      nil
    end
  end

  def active_entries do
    Entry |> where([e], not is_nil(e.current_video_id))
  end

  def for_letter(query, letter) do
    query
    |> query_for_letter(letter)
    |> order_by(fragment("lower(text)"))
  end

  defp query_for_letter(query, letter) do
    cond do
      String.match?(letter, ~r/^[a-zA-Z]$/) ->
        query |> where([e], fragment("text ~* ?", ^"^#{letter}.*"))
      String.match?(letter, ~r/^0-9$/) ->
        query |> where([e], fragment("text ~* ?", ^"^[0-9].*"))
      true ->
        query |> where([e], fragment("text ~* ?", ^"^A.*"))
    end
  end

  defp trim_fields(changeset) do
    changeset
    |> do_trim_field(:text)
    |> do_trim_field(:description)
  end

  defp do_trim_field(changeset, field) do
    if changeset.changes[field] do
      put_change(changeset, field, String.trim(changeset.changes[field]))
    else
      put_change(changeset, field, "")
    end
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
    |> Video.with_vote_count
  end

  def update_current_video(entry) do
    SQL.query(Repo,
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

  def search(locale, search) do
    qry = """
      select id from entries where current_video_id is not null and
        fulltext_search @@ to_tsquery('#{postgres_locale(locale)}',
                                      unaccent($1));
    """
    res = SQL.query!(
      Repo, qry, [
        PostgresQueryHelper.format_search_query(search)
      ]
    )
    ids = Enum.map(res.rows, fn(row) -> List.first(row) end)
    query = from(entry in Entry, where: entry.id in ^ids,
                 order_by: fragment("levenshtein(?, ?)", entry.text, ^search)
               )
    query
    |> Entry.with_current_video
    |> Repo.all
  end

  defp postgres_locale(locale) do
    # The locale is mapped to a postgres string
    # here. If you add a new language here, you also
    # have to change the database trigger to have
    # this new language in there, too.
    cond do
      locale == "de" -> "german"
      locale == "en" -> "english"
      true -> "simple"
    end
  end

end

defimpl Phoenix.Param, for: SignDict.Entry do
  def to_param(%{text: text, id: id}) do
    SignDict.Permalink.to_permalink(id, text)
  end
end
