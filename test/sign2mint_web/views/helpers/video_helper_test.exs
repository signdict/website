defmodule Sign2MintWeb.Helpers.VideoHelperTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias Sign2MintWeb.Helpers.VideoHelper

  describe "is_recommended/1" do
    test "it returns true if entry is recommended" do
      video =
        insert(:video,
          metadata: %{
            "source_json" => %{
              "Empfehlung:" => "X"
            }
          }
        )

      assert VideoHelper.is_recommended(video)
    end

    test "it returns false if entry is not recommended" do
      video =
        insert(:video,
          metadata: %{
            "source_json" => %{
              "Empfehlung:" => ""
            }
          }
        )

      refute VideoHelper.is_recommended(video)
    end

    test "it returns false if source_json is in wrong format" do
      video = insert(:video, metadata: %{})

      refute VideoHelper.is_recommended(video)
    end
  end
end
