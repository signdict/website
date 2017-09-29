defmodule SignDict.UserSignUpTest do
  use SignDict.AcceptanceCase, async: true

  alias SignDict.User

  test "sign up user, login and logout", %{session: session} do
    session
    |> resize_window(1200, 600)
    |> visit("/")
    |> click(Query.link("Register"))
    |> find(Query.css(".user-form"), fn(form) ->
      form
      |> fill_in(Query.text_field("user_email"), with: "new_user@example.com")
      |> fill_in(Query.text_field("user_password"), with: "mylongpassword")
      |> fill_in(Query.text_field("user_password_confirmation"), with: "mylongpassword")
      |> fill_in(Query.text_field("user_name"), with: "Elisa Example")
      |> click(Query.button("Register"))
    end)
    assert current_path(session) == "/"

    User
    |> Repo.get_by!(unconfirmed_email: "new_user@example.com")
    |> User.admin_changeset(%{email: "new_user@example.com"})
    |> Repo.update()

    session
    |> resize_window(1200, 600)
    |> click(Query.link("Sign in"))
    |> find(Query.css(".login-form"), fn(form) ->
      form
      |> fill_in(Query.text_field("session_email"), with: "new_user@example.com")
      |> fill_in(Query.text_field("session_password"), with: "mylongpassword")
      |> click(Query.button("Log in"))
    end)
    |> assert_alert("Successfully signed in")
    |> visit("/")
    |> click(Query.button("Sign out"))
    |> assert_alert("Successfully signed out")
  end

end
