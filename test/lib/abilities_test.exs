defmodule Canada.CanTest do
  use ExUnit.Case, async: true

  alias SignDict.User

  test "an admin can do it all" do
    assert Canada.Can.can?(%User{role: "admin"}, nil, SignDict.Video)
  end

  test "a normal user can do nothing" do
    refute Canada.Can.can?(%User{}, nil, nil)
  end
end
