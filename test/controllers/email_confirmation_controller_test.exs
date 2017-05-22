defmodule SignDict.EmailConfirmationControllerTest do
  use SignDict.ConnCase
  use Bamboo.Test

  import SignDict.Factory

  describe "update/2" do

    test "it renders an error if user can't be found", %{conn: conn} do
      insert(:user, unconfirmed_email: "confirm-1@example.com", confirmation_token: Comeonin.Bcrypt.hashpwsalt("encryptedtoken"))
      conn = conn
             |> get(email_confirmation_path(conn, :update, email: "notfound@example.com", confirmation_token: "token"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "Invalid confirmation link."
    end

    test "it renders an error if the token is wrong", %{conn: conn} do
      insert(:user, unconfirmed_email: "confirm-2@example.com", confirmation_token: Comeonin.Bcrypt.hashpwsalt("encryptedtoken"))
      conn = conn
             |> get(email_confirmation_path(conn, :update, email: "confirm-2@example.com", confirmation_token: "token"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "Unable to confirm your email address."
    end

    test "it signs in the user and confirms the email address and redirects to welcome", %{conn: conn} do
      insert(:user, unconfirmed_email: "confirm-3@example.com", confirmation_token: Comeonin.Bcrypt.hashpwsalt("encryptedtoken"))
      conn = conn
             |> get(email_confirmation_path(conn, :update, email: "confirm-3@example.com", confirmation_token: "encryptedtoken"))
      assert redirected_to(conn) == "/welcome"
      assert Repo.get_by!(SignDict.User, email: "confirm-3@example.com")
    end

    test "it signs in the user and confirms the email address and redirects to the landing page if it was just a change", %{conn: conn} do
      insert(:user, unconfirmed_email: "confirm-3@example.com", confirmation_token: Comeonin.Bcrypt.hashpwsalt("encryptedtoken"))
      conn = conn
             |> get(email_confirmation_path(conn, :update, email: "confirm-3@example.com", change: "true", confirmation_token: "encryptedtoken"))
      assert redirected_to(conn) == "/"
      assert Repo.get_by!(SignDict.User, email: "confirm-3@example.com")
    end
  end

end
