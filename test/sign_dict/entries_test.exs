defmodule SignDict.EntriesTest do
  use SignDict.ConnCase
  import SignDict.Factory

  alias SignDict.Entries

  describe "sign_count/1" do
    test "Counts the published videos" do
      insert(:entry_with_current_video, text: "Banana")
      insert(:entry_with_current_video, text: "Apple")

      assert Entries.sign_count("signdict.org") == 8
    end

    test "does not count videos from another domain" do
      insert(:entry_with_current_video, text: "Cherry")

      domain = insert(:domain, domain: "example.com")
      other_domain_entry = insert(:entry, %{text: "hausbau", domains: [domain]})
      insert(:video_published, %{entry: other_domain_entry})

      assert Entries.sign_count("example.com") == 1
    end
  end
end
