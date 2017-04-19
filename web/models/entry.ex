defmodule SignDict.Entry do
  use SignDict.Web, :model

  @types ~w(word phrase example)

  @primary_key {:id, SignDict.Permalink, autogenerate: true}
  schema "entries" do
    field :text, :string
    field :description, :string
    field :type, :string
    belongs_to :language, SignDict.Language
    has_many :videos, SignDict.Video

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

end

defimpl Phoenix.Param, for: SignDict.Entry do
  def to_param(%{text: text, id: id}) do
    SignDict.Permalink.to_permalink(id, text)
  end
end
