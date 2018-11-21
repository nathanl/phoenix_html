defmodule Phoenix.HTML.EngineTest do
  use ExUnit.Case, async: true

  @template """
  start: <%= 123 %>
  <%= if @foo do %>
    <%= 456 %>
  <% end %>
  <%= 789 %>
  """

  test "encode_to_iodata!" do
    assert Phoenix.HTML.Engine.encode_to_iodata!("<foo>") == "&lt;foo&gt;"
    assert Phoenix.HTML.Engine.encode_to_iodata!({:safe, "<foo>"}) == "<foo>"
    assert Phoenix.HTML.Engine.encode_to_iodata!(123) == "123"
  end

  test "evaluates expressions with buffers" do
    assert eval(@template, %{foo: true}) == "start: 123\n\n  456\n\n789\n"
  end

  test "evaluates safe expressions" do
    assert eval("Safe <%= {:safe, \"value\"} %>", %{}) == "Safe value"
  end

  test "raises ArgumentError for missing assigns" do
    assert_raise ArgumentError,
                 ~r/assign @foo not available in eex template.*Available assigns: \[:bar\]/s,
                 fn ->
                   eval(@template, %{bar: "baz"})
                 end
  end

  defp eval(string, assigns) do
    {:safe, io} =
      EEx.eval_string(string, [assigns: assigns], file: __ENV__.file, engine: Phoenix.HTML.Engine)

    IO.iodata_to_binary(io)
  end
end
