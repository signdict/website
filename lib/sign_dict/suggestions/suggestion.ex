defmodule SignDict.Suggestions.Suggestion do
  use SignDictWeb, :model

  schema "suggestions" do
    belongs_to :user, SignDict.User
    belongs_to :domain, SignDict.Domain

    field :word, :string
    field :description, :string

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:domain_id, :user_id, :word, :description])
    |> validate_required([:word])
    |> foreign_key_constraint(:domain_id)
    |> foreign_key_constraint(:user_id)
  end
end
