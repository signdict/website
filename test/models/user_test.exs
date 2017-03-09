defmodule SignDict.UserTest do
  use SignDict.ModelCase

  alias SignDict.User

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
end
