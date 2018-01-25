defmodule SignDict.SerialzerTest do
  use ExUnit.Case, async: true

  import SignDict.Factory

  alias SignDict.Serializer
  alias SignDict.User

  describe "serialize a user" do
    test "it serializes an user with an email address" do
      user = build(:user)

      assert Serializer.to_map(user) == %{
               user: %{
                 id: user.id,
                 name: user.name,
                 email: user.email,
                 avatar: User.avatar_url(user)
               }
             }
    end

    test "it serializes an user with an unconfirmed email address" do
      user = build(:user, email: nil, unconfirmed_email: "unconfirmed@example.com")

      assert Serializer.to_map(user) == %{
               user: %{
                 id: user.id,
                 name: user.name,
                 email: user.unconfirmed_email,
                 avatar: User.avatar_url(user)
               }
             }
    end
  end
end
