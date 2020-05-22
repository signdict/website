defmodule Canada.CanTest do
  use ExUnit.Case, async: true

  alias SignDict.Entry
  alias SignDict.Language
  alias SignDict.User
  alias SignDict.Video

  test "an admin can do it all" do
    assert Canada.Can.can?(%User{role: "admin"}, nil, SignDict.Video)
  end

  test "a normal user can do nothing" do
    refute Canada.Can.can?(%User{}, nil, nil)
  end

  test "an admin can see the backend" do
    assert Canada.Can.can?(%User{role: "admin"}, :show_backend, %{})
  end

  test "an editor can see the backend" do
    assert Canada.Can.can?(%User{role: "editor"}, :show_backend, %{})
  end

  test "a normal user can't see the backend" do
    refute Canada.Can.can?(%User{}, :show_backend, %{})
  end

  test "an editor can edit videos" do
    assert Canada.Can.can?(%User{role: "editor"}, :edit, %Video{})
  end

  test "an editor can edit entries" do
    assert Canada.Can.can?(%User{role: "editor"}, :edit, %Entry{})
  end

  test "an editor can't edit users" do
    refute Canada.Can.can?(%User{id: 3, role: "editor"}, :edit, %User{})
  end

  test "an editor can't edit languages" do
    refute Canada.Can.can?(%User{role: "editor"}, :edit, %Language{})
  end

  test "a normal user can't edit videos" do
    refute Canada.Can.can?(%User{}, :edit, %Video{})
  end

  test "a normal user can't edit entries" do
    refute Canada.Can.can?(%User{}, :edit, %Entry{})
  end

  test "a normal user can't edit users" do
    refute Canada.Can.can?(%User{id: 3}, :edit, %User{})
  end

  test "a normal user can't edit languages" do
    refute Canada.Can.can?(%User{}, :edit, %Language{})
  end

  test "a statistic user can't edit entries" do
    refute Canada.Can.can?(%User{role: "statistic"}, :edit, %Language{})
  end

  test "a statistic user can't edit users" do
    refute Canada.Can.can?(%User{role: "statistic", id: 1}, :edit, %User{})
  end

  test "a statistic user can't edit vidoes" do
    refute Canada.Can.can?(%User{role: "statistic"}, :edit, %Video{})
  end

  test "a statistic user can see the backend" do
    assert Canada.Can.can?(%User{role: "statistic"}, :show_backend, %{})
  end

  test "a statistic user can see the statistic" do
    assert Canada.Can.can?(%User{role: "statistic"}, "statistic", %Entry{})
  end
end
