defmodule SignDict.SuggestionsTest do
  use SignDict.ConnCase
  import SignDict.Factory

  alias SignDict.Suggestions
  alias SignDict.Suggestions.Suggestion

  describe "suggest a new word/3" do
    setup do
      user = insert(:user)
      domain = insert(:domain)
      {:ok, user: user, domain: domain}
    end

    test "adds a new suggestion without a user", %{domain: domain} do
      {:ok, suggestion} = Suggestions.suggest_word(domain, nil, "Dad")

      suggestion = Repo.get(Suggestion, suggestion.id)

      assert suggestion.user_id == nil
      assert suggestion.word == "Dad"
    end

    test "adds a word with a user", %{domain: domain, user: user} do
      {:ok, suggestion} = Suggestions.suggest_word(domain, user, "Mother")

      suggestion = Repo.get(Suggestion, suggestion.id)

      assert suggestion.user_id == user.id
      assert suggestion.word == "Mother"
    end

    test "adds a word with a description", %{domain: domain, user: user} do
      {:ok, suggestion} = Suggestions.suggest_word(domain, user, "Kid", "Offspring")

      suggestion = Repo.get(Suggestion, suggestion.id)

      assert suggestion.user_id == user.id
      assert suggestion.word == "Kid"
      assert suggestion.description == "Offspring"
    end

    test "does not add a word if its empty", %{domain: domain, user: user} do
      {:error, _} = Suggestions.suggest_word(domain, user, "")
    end

    test "does not add a word if the user does not exist", %{domain: domain} do
      {:error, _} = Suggestions.suggest_word(domain, %{id: 99_999_999_999}, "")
    end
  end
end
