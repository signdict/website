defmodule SignDict.PostgresQueryHelperTest do
  use ExUnit.Case, async: true

  alias SignDict.PostgresQueryHelper

  describe "format_search_query/1" do
    test "it splits strings and adds :* to each one" do
      assert PostgresQueryHelper.format_search_query("Homer Simpson") == "Homer:*&Simpson:*"
    end

    test "it also works for abteilung" do
      assert PostgresQueryHelper.format_search_query("Abteilung") == "Abteilung:*"
    end

    test "it also works for banane" do
      assert PostgresQueryHelper.format_search_query("banane") == "banane:*"
    end

    test "it trims the spaces away" do
      assert PostgresQueryHelper.format_search_query("Homer  Simpson ") == "Homer:*&Simpson:*"
    end
  end
end
