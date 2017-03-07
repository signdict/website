defmodule SignDict.UserSignUpTest do
  use SignUp.AcceptanceCase, async: true

  test "sign up user, login and logout", %{session: session} do
    registration = session
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
                   |> find(Query.css(".alert-info"))
                   |> Element.text
    assert registration == "Registration successful"

    log_in = session
             |> visit("/")
             |> click(Query.link("Sign in"))
             |> find(Query.css(".login-form"), fn(form) ->
               form
               |> fill_in(Query.text_field("session_email"), with: "elisa@example.com")
               |> fill_in(Query.text_field("session_password"), with: "mylongpassword")
               |> click(Query.button("Log in"))
             end)
             |> find(Query.css(".alert-info"))
             |> Element.text
    assert log_in == "Successfully signed in"

    log_out = session
              |> visit("/")
              |> click(Query.link("Sign out"))
              |> find(Query.css(".alert-info"))
              |> Element.text

    assert log_out == "Successfully signed out"
  end
end
