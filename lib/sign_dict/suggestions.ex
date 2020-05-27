defmodule SignDict.Suggestions do
  alias SignDict.Suggestions.Suggestion
  alias SignDict.Repo

  def changeset(params \\ %{}) do
    Suggestion.changeset(%Suggestion{}, params)
  end

  def suggest_word(domain, user, word, description \\ nil) do
    Suggestion.changeset(%Suggestion{}, %{
      domain_id: domain && domain.id,
      user_id: user && user.id,
      word: word,
      description: description
    })
    |> Repo.insert()
  end
end
