defmodule Sign2MintWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: Sign2MintWeb

      alias SignDict.Repo
      import Ecto
      import Ecto.Query

      import Canary.Plugs

      import SignDictWeb.Router.Helpers
      import SignDictWeb.Gettext
      import SignDictWeb.Helpers.LayoutHelper
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/sign2mint_web/templates", namespace: SignDictWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [
          get_csrf_token: 0,
          get_flash: 2,
          view_module: 1
        ]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import SignDictWeb.Router.Helpers
      import SignDictWeb.ErrorHelpers
      import SignDictWeb.BlazeHelpers
      import SignDictWeb.Gettext
      import SignDictWeb.Helpers.DateHelper
      import SignDictWeb.Helpers.LayoutHelper
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
