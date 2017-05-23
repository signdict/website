defmodule SignDict.MockChimp do

  def add_member(list_id, :subscribed, email, opts) do
    send self(), {:mock_chimp, list_id, email, opts}
  end

end
