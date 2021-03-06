defmodule Absinthe.Phase.Document.VariablesTest do
  use Absinthe.Case, async: true

  alias Absinthe.{Blueprint, Phase, Pipeline}

  @pre_pipeline [Phase.Parse, Phase.Blueprint]

  @query """
    query Foo($id: ID!) {
      foo(id: $id) {
        bar
      }
    }
    query Profile($age: Int = 36, $name: String!) {
      profile(name: $name, age: $age) {
        id
      }
    }
  """

  describe "when not providing a value for an optional variable with a default value" do
    it "uses the default value" do
      result = input(@query, %{"name" => "Bruce"})
      op = result.operations |> Enum.find(&(&1.name == "Profile"))
      assert op.provided_values == %{
        "age" => %Blueprint.Input.Integer{value: 36, source_location: %Blueprint.Document.SourceLocation{column: nil, line: 6}},
        "name" => %Blueprint.Input.String{value: "Bruce"},
      }
    end
  end

  describe "when providing a value for an optional variable with a default value" do
    it "uses the default value" do
      result = input(@query, %{"age" => 4, "name" => "Bruce"})
      op = result.operations |> Enum.find(&(&1.name == "Profile"))
      assert op.provided_values == %{
        "age" => %Blueprint.Input.Integer{value: 4},
        "name" => %Blueprint.Input.String{value: "Bruce"},
      }
    end
  end

  def input(query, values) do
    {:ok, result} = blueprint(query)
    |> Phase.Document.Variables.run(variables: values)

    result
  end

  defp blueprint(query) do
    {:ok, blueprint, _} = Pipeline.run(query, @pre_pipeline)
    blueprint
  end

end
