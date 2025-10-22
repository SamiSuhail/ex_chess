defmodule ExChess.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_chess,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_ignore_filters: ["test/support/arrange.ex", "test/support/assert.ex"],
    ]
  end

  def application do
    [
      extra_applications: [:logger],
    ]
  end

  defp deps do
    [
      {:freedom_formatter, ">= 2.0.0", only: :dev},
      {:benchee, "~> 1.0", only: :dev},
    ]
  end
end
