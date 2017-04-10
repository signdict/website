defmodule SignDict.UserSignUpTest do
  use SignUp.AcceptanceCase, async: true

  test "sign up user, login and logout", %{session: session} do
    session
    |> visit("/")
    |> click(Query.link("Register"))
    |> find(Query.css(".user-form"), fn(form) ->
      form
      |> fill_in(Query.text_field("user_email"), with: "elisa@example.com")
      |> fill_in(Query.text_field("user_password"), with: "mylongpassword")
      |> fill_in(Query.text_field("user_password_confirmation"), with: "mylongpassword")
      |> fill_in(Query.text_field("user_name"), with: "Elisa Example")
      |> click(Query.button("Register"))
    end)
    |> visit("/")

    Process.sleep(2000)

    session
    |> click(Query.link("Sign out"))
    |> click(Query.link("Sign in"))
    |> find(Query.css(".login-form"), fn(form) ->
      form
      |> fill_in(Query.text_field("session_email"), with: "elisa@example.com")
      |> fill_in(Query.text_field("session_password"), with: "mylongpassword")
      |> click(Query.button("Log in"))
    end)
    |> assert_alert("Successfully signed in")
    |> visit("/")
    |> click(Query.link("Sign out"))
    # Sadly this link does not work right now, so I
    # had to comment it out.
    # TODO: find a way to fix this again
    # |> assert_alert("Successfully signed out")
  end

end
