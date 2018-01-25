defmodule SignDict.MockExq do
  def enqueue(_param, queue, worker, params) do
    send(self(), {:mock_exq, queue, worker, params})
  end
end
