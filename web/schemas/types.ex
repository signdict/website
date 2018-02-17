defmodule SignDict.Schema.Types do
  use Absinthe.Schema.Notation

  @desc "entry"
  object :entry do
    field :text, :string
    field :description, :string
    field :language, :language
    field :type, :string
    field :videos, list_of(:video)
  end

  @desc "language"
  object :language do
    field :long_name, :string
    field :shot_name, :string
    field :iso6393, :string
  end

  @desc "user"
  object :user do
    field :name, :string
    field :email, :string
  end

  @desc "video"
  object :video do
    field :copyright, :string
    field :license, :string
    field :original_href, :string
    field :video_url, :string
    field :thumbnail_url, :string
    field :user, :user
    # field :metadata, :map
  end
end
