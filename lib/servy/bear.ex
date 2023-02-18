defmodule Servy.Bear do
  alias Servy.Bear

  defstruct id: nil, name: "", type: "", hibernating: false

  def is_grizzly(%Bear{type: type}) do
    type == "Grizzly"
  end

  def order_asc_by_name(%Bear{} = bear1, %Bear{} = bear2) do
    bear1 <= bear2
  end
end
