defmodule ExChessServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_chess_server,
      version: "0.1.0",
      build_embedded: Mix.env() == :prod,
      description:
        "ExChess is a, although still primitive, comprehensive implementation of the chess game rules in Elixir.",
      package: package(),
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_ignore_filters: ["test/support/arrange.ex", "test/support/assert.ex"],
      name: "ExChessServer",
      source_url: "https://github.com/SamiSuhail/ex_chess",
      source_url_pattern:
        "https://github.com/SamiSuhail/ex_chess/blob/main/src/ex_chess_server/%{path}#L%{line}",
      homepage_url: "https://github.com/SamiSuhail/ex_chess",
      docs: [
        main: "ExChess",
        source_ref: "main",
        source_url_pattern:
          "https://github.com/SamiSuhail/ex_chess/blob/main/src/ex_chess_server/%{path}#L%{line}",
      ],
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ExChessServer.Application, []},
    ]
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/SamiSuhail/ex_chess/blob/main/src/ex_chess"},
    ]
  end

  defp deps do
    [
      {:freedom_formatter, ">= 2.0.0", only: :dev},
      {:ex_chess, "~> 0.2.0"},
    ]
  end
end
