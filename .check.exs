[
  ## all available options with default values (see `mix check` docs for description)
  # parallel: true,
  # skipped: true,

  ## list of tools (see `mix check` docs for defaults)
  tools: [
    {:ex_unit, deps: [{:credo, status: :ok}]},
    {:npm_test, false}
  ]
]
