defmodule SignDict.Factory do
  use ExMachina.Ecto, repo: SignDict.Repo

  alias Comeonin.Bcrypt

  def user_factory do
    %SignDict.User{
      name: "Jane Smith",
      email: sequence(:email, &"email-#{&1}@example.com"),
      password: "correct_password",
      password_confirmation: "correct_password",
      password_hash: Bcrypt.hashpwsalt("correct_password")
    }
  end

  def user_with_avatar_factory do
    %{user_factory | avatar: "test/fixtures/images/avatar.png"}
  end

  def admin_user_factory do
    %SignDict.User{
      name: "Jane Smith",
      email: sequence(:email, &"email-#{&1}@example.com"),
      password: "correct_password",
      password_confirmation: "correct_password",
      password_hash: Bcrypt.hashpwsalt("correct_password"),
      role: "admin"
    }
  end
end
