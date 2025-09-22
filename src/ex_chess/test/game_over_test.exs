defmodule ExChessTest.GameOverTest do
  use ExUnit.Case
  alias ExChessTest.{Arrange, Assert}

  test "checkmate" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |       k| 8
      7 | R      | 7
      6 |R       | 6
      5 |pp      | 5
      4 |PP      | 4
      3 |r       | 3
      2 | r      | 2
      1 |       K| 1
        ----------
         abcdefgh
      """)

    Arrange.game_move(game, "a6a8")
    |> Assert.checkmate(:white)

    Arrange.game_turn(game, :black)
    |> Arrange.game_move("a3a1")
    |> Assert.checkmate(:black)
  end

  test "stalemate" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |        | 8
      7 |        | 7
      6 |        | 6
      5 |        | 5
      4 |p       | 4
      3 |    p   | 3
      2 |P   Pp p| 2
      1 |     K k| 1
        ----------
         abcdefgh
      """)

    Arrange.game_move(game, "a2a3")
    |> Assert.stalemate()

    Arrange.game_turn(game, :black)
    |> Arrange.game_move("a4a3")
    |> Assert.stalemate()
  end
end
