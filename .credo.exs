# config/.credo.exs
%{
  configs: [
    %{
      name: "default",
      color: true,
      files: %{
        included: ["lib/", "src/", "web/", "apps/"],
        excluded: [~r"/_build/", ~r"/deps/", "tests/"]
      },
      checks: [
        {Credo.Check.Readability.Specs, false},
        {Credo.Check.Readability.ModuleDoc, false}
      ]
    }
  ]
}
