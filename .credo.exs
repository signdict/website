# config/.credo.exs
%{
  configs: [
    %{
      name: "default",
      color: true,
      files: %{
        included: ["lib/", "src/", "web/", "apps/", "test/"],
        excluded: []
      },
      checks: [
        {Credo.Check.Readability.Specs, false},
        {Credo.Check.Readability.ModuleDoc, false}
      ]
    }
  ]
}
