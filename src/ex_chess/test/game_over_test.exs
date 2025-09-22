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
end
