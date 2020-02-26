defmodule FormatterIssue do
  @moduledoc """
  # without piping twice:
  def call(args) do
    function_a(&@implementation.make_call/2, [args, %{}])
    |> function_b()
  end

  # attempt to pipe, due to Credo raw value check/suggestion:
  def call(args) do
    &@implementation.make_call/2
    |> function_a([args, %{}])
    |> function_b()
  end

  # Run `mix format`, this is the output:
  def call(args) do
    &((@implementation.make_call / 2)
      |> function_a([args, %{}])
      |> function_b())
  end

  # try `mix compile`:
  == Compilation error in file lib/formatter_issue.ex ==
  ** (CompileError) lib/formatter_issue.ex:31: invalid args for &, expected an expression in the format of &Mod.fun/arity, &local/arity or a capture containing at least one argument as &1, got: @implementation.make_call() / 2 |> function_a([args, %{}]) |> function_b()

  # "fix it", then run `mix format`, output:
  def call(args) do
    fun = &@implementation.make_call/2

    fun
    |> function_a([args, %{}])
    |> function_b()
  end
  """

  defmodule FormatterIssue.Implementation do
    def make_call(a, b) do
      {:ok, "#{a}#{b}"}
    end
  end

  @implementation FormatterIssue.Implementation

  def call(args) do
    fun = &@implementation.make_call/2

    fun
    |> function_a([args, %{}])
    |> function_b()
  end

  defp function_a(fun, opts) do
    fun.(opts)
  end

  defp function_b(input) do
    input
  end
end
