defmodule SignDict.UserPasswordResetTest do
  use SignDict.AcceptanceCase, async: true
  import SignDict.Factory

  test "send rest email", %{session: session} do
    user = insert(:user, email: "reset_email@example.com")
    session
    |> resize_window(1200, 600)
    |> visit("/")
    |> click(Query.link("Sign in"))
    |> click(Query.link("Forgot password?"))
    |> find(Query.css(".password-reset-form"), fn(form) ->
      form
      |> fill_in(Query.text_field("user_email"), with: user.email)
      |> click(Query.button("Send password reset instructions"))
    end)
    |> assert_alert("You'll receive an email with instructions about how to reset your password in a few minutes.")
  end

  test "reset email and login", %{session: session} do
    user = insert(:user, email: "reset_login@example.com", password_reset_token: Comeonin.Bcrypt.hashpwsalt("12345"))
    session
    |> resize_window(1200, 600)
    |> visit("/password/edit?email=#{user.email}&password_reset_token=#{12345}")
    |> find(Query.css(".password-reset-form"), fn(form) ->
      form
      |> fill_in(Query.text_field("user_password"), with: "mynewpassword")
      |> fill_in(Query.text_field("user_password_confirmation"), with: "mynewpassword")
      |> click(Query.button("Change my password"))
    end)
    |> assert_alert("Password successfully changed")
    |> click(Query.link("Sign in"))
    |> find(Query.css(".login-form"), fn(form) ->
      form
      |> fill_in(Query.text_field("session_email"), with: user.email)
      |> fill_in(Query.text_field("session_password"), with: "mynewpassword")
      |> click(Query.button("Log in"))
    end)
    |> assert_alert("Successfully signed in")
  end
end
