# ExChessServer

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_chess_server` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_chess_server, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_chess_server>.


Notes:
- If player hasn't reconnected within 30 seconds they've abandoned
- Cleanup dead subscribers (monitor)
- Autosubscribe on connect + unsubscribe on disconnect
- Capture game server exits and persist state

- Benchmarks
  - When making move get a diffcheck reply rather than full state (update downstream)
  - Partition supervisor


Split `ExChess` into server vs client-side state to reduce message size -> only diff needs to be sent.
  server:
    status
    active_color
    board
    en_passant_file
    castling_rights
    repetition_history
    max_repetitions
    halfmove_clock
    fullmove_number
    time
    history

  client:
    diff:
      board
      draw_claimable?
      active_color
      fullmove_number
      time
      history