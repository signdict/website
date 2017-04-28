defmodule SignDict.PostgresQueryHelperTest do
  use ExUnit.Case, async: true

  alias SignDict.PostgresQueryHelper

  describe "format_search_query/1" do
    test "it splits strings and adds :* to each one" do
      assert PostgresQueryHelper.format_search_query("Homer Simpson") == "Homer:*&Simpson:*"
    end
  end
end
