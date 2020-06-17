defmodule SignDictWeb.Helpers.LayoutHelper do
  def get_layout_for(domain, layout) do
    if domain == Application.get_env(:sign_dict, :sign2mint_domain) do
      {Sign2MintWeb.LayoutView, layout}
    else
      {SignDictWeb.LayoutView, layout}
    end
  end

  def render_shared(domain, file, params) do
    if domain == Application.get_env(:sign_dict, :sign2mint_domain) do
      Phoenix.View.render(Sign2MintWeb.SharedView, file, params)
    else
      Phoenix.View.render(SignDictWeb.SharedView, file, params)
    end
  end
end
