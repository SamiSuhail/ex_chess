# ExChess

ExChess is a, although still primitive, comprehensive implementation of the chess game rules in Elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_chess` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_chess, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_chess>.

## Project structure

### `lib/*`
```bash
lib
├── ex_chess
│   ├── board.ex
│   ├── fen.ex
│   ├── game.ex
│   ├── move.ex
│   ├── piece.ex
│   ├── square.ex
│   └── visualization.ex
├── ex_chess_core
│   ├── move_context.ex
│   ├── move_evaluation.ex
│   ├── move_generation.ex
│   ├── piece_patterns.ex
│   ├── piece_rules
│   │   ├── king_rules.ex
│   │   ├── knight_rules.ex
│   │   ├── linear_piece_rules.ex
│   │   └── pawn_rules.ex
│   ├── piece_rules.ex
│   ├── san.ex
│   ├── search.ex
│   └── state
│       ├── board_manager.ex
│       └── game_manager.ex
└── ex_chess.ex
```

The modules inside the `ex_chess.ex` file and `ex_chess` directory are the library's API, everything inside `ex_chess_core` is internal and only exposed via the `ExChess` module.


