defmodule SignDictWeb.Schema.Types do
  use Absinthe.Schema.Notation

  @desc "entry"
  object :entry do
    field(:id, :integer)
    field(:text, :string)
    field(:description, :string)
    field(:language, :language)
    field(:type, :string)
    field(:current_video, :video)
    field(:videos, list_of(:video))
    field(:url, :string)
  end

  @desc "language"
  object :language do
    field(:long_name, :string)
    field(:short_name, :string)
    field(:iso6393, :string)
  end

  @desc "user"
  object :user do
    field(:name, :string)
  end

  @desc "video"
  object :video do
    field(:copyright, :string)
    field(:license, :string)
    field(:original_href, :string)
    field(:video_url, :string)
    field(:thumbnail_url, :string)
    field(:user, :user)
    field(:url, :string)
    field(:updated_at, :string)
  end
end
