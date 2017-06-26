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

    test "it moves the email to unconfirmed_email and sets the confirmation fields and sents an email" do
      params = @valid_attrs
      changeset = User.changeset(%User{email: "oldemail@example.com"}, params)
      assert changeset.valid?
      assert {:changes, "elisa@example.com"} == Ecto.Changeset.fetch_field(changeset, :unconfirmed_email)
      assert {:data, "oldemail@example.com"} == Ecto.Changeset.fetch_field(changeset, :email)
      assert {:changes, _data} = Ecto.Changeset.fetch_field(changeset, :confirmation_token)
      assert {:changes, _data} = Ecto.Changeset.fetch_field(changeset, :confirmation_token_unencrypted)
    end

    test "it sets the email to nil if it is new and moves it to the unconfirmed_email field" do
      params = @valid_attrs
      changeset = User.changeset(%User{}, params)
      assert changeset.valid?
      assert {:changes, "elisa@example.com"} == Ecto.Changeset.fetch_field(changeset, :unconfirmed_email)
      assert {:data, nil} == Ecto.Changeset.fetch_field(changeset, :email)
    end

    test "it is invalid if the email already exists in the unconfirmed_email field" do
      insert :user, %{unconfirmed_email: "elisa@example.com"}
      changeset = User.changeset(%User{}, @valid_attrs)
      refute changeset.valid?
    end

    test "it is invalid if the email adready exists in the email field" do
      insert :user, %{email: "elisa@example.com"}
      changeset = User.changeset(%User{}, @valid_attrs)
      refute changeset.valid?
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

    test "update flags if present" do
      changeset = User.admin_changeset(%User{}, %{"flags" => ["recording"]})
      assert Ecto.Changeset.fetch_field(changeset, :flags) == {:changes, ["recording"]}
    end

    test "it does not remove a flag when params is empty" do
      changeset = User.admin_changeset(%User{flags: ["recording"]}, %{})
      assert Ecto.Changeset.fetch_field(changeset, :flags) == {:data, ["recording"]}
    end

    test "it removes the flag if params are present but flags is not" do
      changeset = User.admin_changeset(%User{flags: ["recording"]}, %{"other" => "other"})
      assert Ecto.Changeset.fetch_field(changeset, :flags) == {:changes, []}
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

    test "it moves the email to unconfirmed_email and sets the confirmation fields and sents an email" do
      params = @valid_attrs
      changeset = User.register_changeset(%User{email: "oldemail@example.com"}, params)
      assert changeset.valid?
      assert {:changes, "elisa@example.com"} == Ecto.Changeset.fetch_field(changeset, :unconfirmed_email)
      assert {:data, "oldemail@example.com"} == Ecto.Changeset.fetch_field(changeset, :email)
      assert {:changes, _data} = Ecto.Changeset.fetch_field(changeset, :confirmation_token)
    end

    test "it sets the email to nil if it is new and moves it to the unconfirmed_email field" do
      params = @valid_attrs
      changeset = User.register_changeset(%User{}, params)
      assert changeset.valid?
      assert {:changes, "elisa@example.com"} == Ecto.Changeset.fetch_field(changeset, :unconfirmed_email)
      assert {:data, nil} == Ecto.Changeset.fetch_field(changeset, :email)
    end

    test "it is invalid if the email already exists in the unconfirmed_email field" do
      insert :user, %{unconfirmed_email: "elisa@example.com"}
      changeset = User.register_changeset(%User{}, @valid_attrs)
      refute changeset.valid?
    end

    test "it is invalid if the email adready exists in the email field" do
      insert :user, %{email: "elisa@example.com"}
      changeset = User.register_changeset(%User{}, @valid_attrs)
      refute changeset.valid?
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

  describe "User.avatar_url/1" do
    test "it returns a gravatar url if no image is uploaded" do
      user = build :user, email: "bodo@tasche.me"
      assert User.avatar_url(user) == "https://secure.gravatar.com/avatar/f3c4a818db15623a3f4fd035d781e8ee?s=256"
    end

    test "it returns a user uploaded image if one was uploaded" do
      user = build :user_with_avatar, email: "bodo@tasche.me"
      assert User.avatar_url(user) =~ "/uploads/user/avatars/thumb.png"
    end
  end

  describe "User.admin?/1" do
    test "for admins it returns true" do
      assert User.admin?(%User{role: "admin"})
    end

    test "for non admins it returns false" do
      refute User.admin?(%User{role: "user"})
    end
  end

  describe "confirm_sent_at_changeset/1" do
    test "it updates the confirmation_sent_at" do
      changeset = User.confirm_sent_at_changeset(%User{email: "oldemail@example.com"})
      assert changeset.valid?
      assert {:changes, _timestamp} = Ecto.Changeset.fetch_field(changeset, :confirmation_sent_at)
    end
  end

  describe "confirm_email_changeset/1" do
    test "it confirms the email if it is valid" do
      user = insert(:user,
        confirmation_token: Comeonin.Bcrypt.hashpwsalt("12345"),
        unconfirmed_email: "elisa@example.com"
      )
      changeset = User.confirm_email_changeset(user, %{
        confirmation_token_unencrypted: "12345",
      })
      assert changeset.valid?
      assert {:changes, "elisa@example.com"} = Ecto.Changeset.fetch_field(changeset, :email)
      assert {:changes, nil}                 = Ecto.Changeset.fetch_field(changeset, :unconfirmed_email)
      assert {:changes, _confirmed_at}       = Ecto.Changeset.fetch_field(changeset, :confirmed_at)
    end

    test "it does not confirm if the token is wrong" do
      changeset = User.confirm_email_changeset(%User{
        confirmation_token: Comeonin.Bcrypt.hashpwsalt("12345"),
        unconfirmed_email: "elisa@example.com"
      }, %{
        confirmation_token_unencrypted: "23456",
      })
      refute changeset.valid?
    end

    test "it does not confirm the email if it is already present" do
      insert :user, email: "elisa@example.com"
      user = insert :user,
        confirmation_token: Comeonin.Bcrypt.hashpwsalt("12345"),
        unconfirmed_email: "elisa@example.com"
      changeset = User.confirm_email_changeset(user, %{
        confirmation_token_unencrypted: "12345",
      })
      assert {:error, _changeset} = Repo.update(changeset)
    end
  end

  describe "subscribe_to_newsletter/1" do
    test "It subscribes to the newsletter with the email" do
      user = insert :user, email: "elisa@example.com", name: "user name"
      User.subscribe_to_newsletter(user)
      assert_received {:mock_chimp, "f96556b89f", "elisa@example.com", %{"FULL_NAME" => "user name"}}
    end

    test "It subscribes to the newsletter with the unconfirmed_email if email is not present" do
      user = insert :user, email: nil, unconfirmed_email: "elisa@example.com", name: "user name"
      User.subscribe_to_newsletter(user)
      assert_received {:mock_chimp, "f96556b89f", "elisa@example.com", %{"FULL_NAME" => "user name"}}
    end
  end

  describe "Phoenix.Param" do
    test "it creates a nice permalink for the user" do
      assert Phoenix.Param.to_param(%User{id: 1, name: "My name is my castle!"}) == "1-my-name-is-my-castle"
    end
  end

  describe "User.has_flag?" do
    test "it returns true if feature is present" do
      user = insert :user, flags: ["recording"]
      assert User.has_flag?(user, "recording")
    end

    test "it returns false if feature is not present" do
      user = insert :user, flags: ["another_flag"]
      refute User.has_flag?(user, "recording")
    end

    test "it returns false if user is nil" do
      refute User.has_flag?(nil, "recording")
    end

    test "it returns false if flags is nil" do
      user = insert :user, flags: nil
      refute User.has_flag?(user, "recording")
    end
  end

  describe "User.all_editors" do
    test "it returns a list of editors" do
      insert :admin_user
      insert :user
      editor = insert :editor_user
      assert [editor.email] == Enum.map(User.all_editors, fn(user) -> user.email end)
    end
  end

end
