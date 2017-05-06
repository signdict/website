defmodule SignDict.JwPlayer.ClientTest do
  use ExUnit.Case, async: true

  test "it generates a corectly sigend url" do
    result = "http://api.jwplatform.com/v1videos/list?api_format=xml&api_key=API_KEY&api_nonce=80684843&api_timestamp=1237387851&text=d%C3%A9mo&api_signature=9e7f22b83a183cc5076faffc3068fbba4c53f4c4"
    assert JwPlayer.Client.sign_url("videos/list", %{text: "démo", api_nonce: "80684843", api_timestamp: "1237387851", api_format: "xml"}) == result
  end

end
