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
- Server will start with noone connected
- Players (clients) then connect to the server and it stores their pids + monitors for exit
- When client process exits player is considered disconnected
- If player hasn't reconnected within 30 seconds they've abandoned
- Player disconnect/abandon events can be subscribed to
- When player disconnect/abandon event occurs notify all subscribers
- Limit subscribers
- Cleanup dead subscribers (monitor)
- Autosubscribe on connect + unsubscribe on disconnect

- Benchmarks
  - When making move get a diffcheck reply rather than full state (update downstream)
  - Partition supervisor