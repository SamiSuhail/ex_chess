default_game = ExChess.Game.new()
kiwipete_game = ExChess.Fen.to_game("r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1")

Benchee.run(
  %{
    "default_3" => fn -> ExChessCore.Search.run(default_game, 3) end,
    "kiwipete_2" => fn -> ExChessCore.Search.run(kiwipete_game, 2) end
  },
  time: 10,
  memory_time: 5
)
