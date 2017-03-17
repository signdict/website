defmodule SignDict.UserTest do
  use SignDict.ModelCase

  import SignDict.Factory

  alias SignDict.User

  describe "User.changeset/2" do
    @valid_attrs %{
      email: "elisa@example.com",
      password: "valid_password",
      password_confirmation: "valid_password",
      name: "some content",
      biography: "some content"
    }

    test "is valid when adding all the fields" do
      changeset = User.changeset(%User{}, @valid_attrs)
      assert changeset.valid?
    end

    test "is invalid when password does not match" do
      params = Map.put(@valid_attrs, :password_confirmation, "invalid_password")
      changeset = User.changeset(%User{}, params)
      refute changeset.valid?
    end

    test "is invalid if email is wrong" do
      params = Map.put(@valid_attrs, :email, "invalid_email")
      changeset = User.changeset(%User{}, params)
      refute changeset.valid?
    end

    test "it hashes the password if it is given" do
      changeset = User.changeset(%User{}, @valid_attrs)
      assert Ecto.Changeset.fetch_field(changeset, :password_hash) != :error
    end

    test "it requires a password if the user is new" do
      params = @valid_attrs
               |> Map.delete(:password)
               |> Map.delete(:password_confirmation)
      changeset = User.changeset(%User{}, params)
      refute changeset.valid?
    end

    test "it does not require a password if the user is already stored in the database" do
      user = insert :user
      params = @valid_attrs
               |> Map.delete(:password)
               |> Map.delete(:password_confirmation)
      changeset = User.changeset(user, params)
      assert changeset.valid?
    end
  end

  describe "User.admin_changeset/2" do
    @valid_attrs %{
      email: "elisa@example.com",
      password: "valid_password",
      password_confirmation: "valid_password",
      name: "some content",
      biography: "some content"
    }

    test "is valid when adding all the fields" do
      changeset = User.admin_changeset(%User{}, @valid_attrs)
      assert changeset.valid?
    end

    test "is invalid when password does not match" do
      params = Map.put(@valid_attrs, :password_confirmation, "invalid_password")
      changeset = User.admin_changeset(%User{}, params)
      refute changeset.valid?
    end

    test "is invalid if email is wrong" do
      params = Map.put(@valid_attrs, :email, "invalid_email")
      changeset = User.admin_changeset(%User{}, params)
      refute changeset.valid?
    end

    test "it hashes the password if it is given" do
      changeset = User.admin_changeset(%User{}, @valid_attrs)
      assert Ecto.Changeset.fetch_field(changeset, :password_hash) != :error
    end

    test "it requires a password if the user is new" do
      params = @valid_attrs
               |> Map.delete(:password)
               |> Map.delete(:password_confirmation)
      changeset = User.admin_changeset(%User{}, params)
      refute changeset.valid?
    end

    test "it does not require a password if the user is already stored in the database" do
      user = insert :user
      params = @valid_attrs
               |> Map.delete(:password)
               |> Map.delete(:password_confirmation)
      changeset = User.admin_changeset(user, params)
      assert changeset.valid?
    end
  end

  describe "User.register_changeset/2" do
    @valid_attrs %{
      email: "elisa@example.com",
      password: "valid_password",
      password_confirmation: "valid_password",
      name: "some content",
      biography: "some content"
    }
    @invalid_attrs %{}

    test "changeset with valid attributes" do
      changeset = User.register_changeset(%User{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = User.register_changeset(%User{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "is invalid when password does not match" do
      params = Map.put(@valid_attrs, :password_confirmation, "invalid_password")
      changeset = User.register_changeset(%User{}, params)
      refute changeset.valid?
    end

    test "it hashes the password" do
      changeset = User.register_changeset(%User{}, @valid_attrs)
      assert Ecto.Changeset.fetch_field(changeset, :password_hash) != :error
    end
  end

  describe "User.create_reset_password_changeset/1" do
    test "it creates a new token and stores it encrypted" do
      changeset = User.create_reset_password_changeset(%User{})
      {_state, unencrypted} = Ecto.Changeset.fetch_field(changeset, :password_reset_unencrypted)
      {_state, encrypted}   = Ecto.Changeset.fetch_field(changeset, :password_reset_token)
      assert Comeonin.Bcrypt.checkpw(unencrypted, encrypted)
    end
  end

  describe "User.reset_password_changeset/2" do
    test "it throws an errror if no password is given" do
      changeset = User.reset_password_changeset(%User{}, %{})
      refute changeset.valid?
    end

    test "it throws an error if token is wrong" do
      changeset = User.reset_password_changeset(%User{
        password_reset_token: Comeonin.Bcrypt.hashpwsalt("iamwrong")
      }, %{
        password_reset_unencrypted: "12345",
        password: "newpassword",
        password_confirmation: "newpassword"
      })
      refute changeset.valid?
    end

    test "it throws an error if password and confirmation missmatch" do
      changeset = User.reset_password_changeset(%User{
        password_reset_token: Comeonin.Bcrypt.hashpwsalt("12345")
      }, %{
        password_reset_unencrypted: "12345",
        password: "newpassword",
        password_confirmation: "wrong"
      })
      refute changeset.valid?
    end

    test "it updates the password if everything is correct" do
      changeset = User.reset_password_changeset(%User{
        password_reset_token: Comeonin.Bcrypt.hashpwsalt("12345")
      }, %{
        password_reset_unencrypted: "12345",
        password: "newpassword",
        password_confirmation: "newpassword"
      })
      assert changeset.valid?
    end
  end
end
