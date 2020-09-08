defmodule Sign2MintWeb.Helpers.VideoHelperTest do
  use SignDict.ConnCase

  import SignDict.Factory

  alias Sign2MintWeb.Helpers.VideoHelper

  describe "department/1" do
    test "it returns the list of departments" do
      video =
        insert(:video,
          metadata: %{
            filter_data: %{
              "fachgebiet" => ["Medizin", "Chemie"]
            }
          }
        )

      assert VideoHelper.department(video) == ["Medizin", "Chemie"]
    end

    test "it returns an empty list for malformed metadata" do
      video = insert(:video, metadata: %{})

      assert VideoHelper.department(video) == []
    end
  end

  describe "color_for_department/1" do
    test "it returns a nice color classname" do
      assert VideoHelper.color_for_department("Chemie") == "s2m--colors--chemie"
    end
  end

  describe "source/1" do
    test "it returns the list of departments" do
      video =
        insert(:video,
          metadata: %{
            filter_data: %{
              "herkunft" => ["neu", "international"]
            }
          }
        )

      assert VideoHelper.source(video) == ["neu", "international"]
    end

    test "it returns an empty list for malformed metadata" do
      video = insert(:video, metadata: %{})

      assert VideoHelper.source(video) == []
    end
  end

  describe "application/1" do
    test "it returns the list of applications" do
      video =
        insert(:video,
          metadata: %{
            filter_data: %{
              "anwendungsbereich" => ["Schule", "Akademie"]
            }
          }
        )

      assert VideoHelper.application(video) == ["Schule", "Akademie"]
    end

    test "it returns an empty list for malformed metadata" do
      video = insert(:video, metadata: %{})

      assert VideoHelper.application(video) == []
    end
  end

  describe "is_recommended/1" do
    test "it returns true if entry is recommended" do
      video =
        insert(:video,
          metadata: %{
            "source_json" => %{
              "metadata" => %{
                "Empfehlung:" => "X"
              }
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
              "metadata" => %{
                "Empfehlung:" => ""
              }
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
