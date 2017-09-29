defmodule SignDict.EntryVotingTest do
  use SignDict.AcceptanceCase, async: true
  import SignDict.Factory

  test "user votes for a video", %{session: session} do
    insert(:user, %{email: "bob@example.com", password: "correct_password", password_confirmation: "correct_password"})
    video = insert(:video_with_entry)

    session
    |> visit("/")
    |> resize_window(1200, 600)
    |> click(Query.link("Sign in"))
    |> find(Query.css(".login-form"), fn(form) ->
      form
      |> fill_in(Query.text_field("session_email"), with: "bob@example.com")
      |> fill_in(Query.text_field("session_password"), with: "correct_password")
      |> click(Query.button("Log in"))
    end)
    |> visit("/entry/#{video.entry.id}")
    |> click(Query.css(".so-voting-box--vote-button"))
    |> find(Wallaby.Query.css(".so-voting-box--count"), fn(count) ->
      assert count
      |> has_text?("1")
    end)
    |> click(Query.css(".so-voting-box--vote-button"))
    |> find(Wallaby.Query.css(".so-voting-box--count"), fn(count) ->
      assert count
      |> has_text?("0")
    end)
  end

end
