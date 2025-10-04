defmodule SignDict.ResetPasswordControllerTest do
  use SignDict.ConnCase
  use Bamboo.Test

  import SignDict.Factory

  setup do
    [user: insert(:user, password_reset_token: Bcrypt.hash_pwd_salt("encryptedtoken"))]
  end

  test "renders form for new resources", %{conn: conn} do
    conn =
      conn
      |> get(Helpers.reset_password_path(conn, :new))

    assert html_response(conn, 200) =~ "Forgot your password?"
  end

  test "sends an email to the user if it exist", %{conn: conn, user: user} do
    conn =
      conn
      |> post(Helpers.reset_password_path(conn, :create), user: %{email: user.email})

    assert redirected_to(conn) == "/"

    assert get_flash(conn, :info) ==
             "You'll receive an email with instructions about how to reset your password in a few minutes."

    assert_email_delivered_with(
      subject: "Your password reset link",
      to: [{user.name, user.email}]
    )
  end

  test "silently fails if the user does not exist", %{conn: conn} do
    conn =
      conn
      |> post(Helpers.reset_password_path(conn, :create), user: %{email: "wrong@example.com"})

    assert redirected_to(conn) == "/"

    assert get_flash(conn, :info) ==
             "You'll receive an email with instructions about how to reset your password in a few minutes."

    assert_no_emails_delivered()
  end

  test "shows the password edit form", %{conn: conn, user: user} do
    conn =
      conn
      |> get(Helpers.reset_password_path(conn, :edit), %{
        email: user.email,
        password_reset_token: user.password_reset_unencrypted
      })

    assert html_response(conn, 200) =~ "Change your password"
  end

  test "redirects if email and token are missing", %{conn: conn} do
    conn =
      conn
      |> get(Helpers.reset_password_path(conn, :edit), %{})

    assert redirected_to(conn) == "/"
    assert get_flash(conn, :error) == "Invalid password reset link. Please try again."
  end

  test "fails to update if the token is wrong", %{conn: conn} do
    conn =
      conn
      |> put(Helpers.reset_password_path(conn, :update), %{})

    assert redirected_to(conn) == "/"
    assert get_flash(conn, :error) == "Invalid password reset link. Please try again."
  end

  test "fails to update if the password does not match confirmation", %{conn: conn, user: user} do
    conn =
      conn
      |> put(Helpers.reset_password_path(conn, :update), %{
        user: %{email: user.email, password_reset_unencrypted: "wrong"}
      })

    assert get_flash(conn, :error) == "Unable to change your password"
    assert html_response(conn, 200) =~ "Change your password"
  end

  test "updates the password if password, confirmation and token are correct", %{
    conn: conn,
    user: user
  } do
    conn =
      conn
      |> put(Helpers.reset_password_path(conn, :update), %{
        user: %{email: user.email, password_reset_unencrypted: "encryptedtoken"}
      })

    assert get_flash(conn, :error) == "Unable to change your password"
    assert html_response(conn, 200) =~ "Change your password"
  end
end
