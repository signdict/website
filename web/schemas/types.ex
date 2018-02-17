defmodule SignDict.Schema.Types do
  use Absinthe.Schema.Notation

  @desc "entry"
  object :entry do
    field :text, :string
    field :description, :string
    field :language, :language
  end

  @desc "language"
  object :language do
    field :long_name, :string
    field :shot_name, :string
    field :iso6393, :string
  end
end
