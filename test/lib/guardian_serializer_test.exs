defmodule SignDict.GuardianSerializerTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias SignDict.GuardianSerializer

  describe "for_token/1" do
    test "returns ok with user id if given a user" do
      user = insert :user
      result = GuardianSerializer.for_token(user)
      assert result == {:ok, "User:#{user.id}"}
    end

    test "returns :error when not given a user" do
      result = GuardianSerializer.for_token("something")
      assert result == {:error, "Unknown resource type"}
    end
  end

  describe "from_token/1" do
    test "it returns the user when given a correct user id" do
      user = insert :user
      result = GuardianSerializer.from_token("User:#{user.id}")
      email = user.email
      assert {:ok, %SignDict.User{email: ^email}} = result
    end

    test "it returns :error when not given a user id" do
      result = GuardianSerializer.from_token("something")
      assert result == {:error, "Unknown resource type"}
    end
  end

end
