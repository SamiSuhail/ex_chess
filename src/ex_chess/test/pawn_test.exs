defmodule ExChessTest.PawnTest do
  use ExUnit.Case
  alias ExChessTest.{Arrange, Assert}

  test "advance" do
    Arrange.new_game()
    |> Arrange.game_move("a2a3")
    |> Arrange.game_move("a7a6")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |rnbqkbnr| 8
    7 | ppppppp| 7
    6 |p       | 6
    5 |        | 5
    4 |        | 4
    3 |P       | 3
    2 | PPPPPPP| 2
    1 |RNBQKBNR| 1
      ----------
       abcdefgh
    """)
  end

  test "advance two ranks" do
    Arrange.new_game()
    |> Arrange.game_move("a2a4")
    |> Arrange.game_move("a7a5")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |rnbqkbnr| 8
    7 | ppppppp| 7
    6 |        | 6
    5 |p       | 5
    4 |P       | 4
    3 |        | 3
    2 | PPPPPPP| 2
    1 |RNBQKBNR| 1
      ----------
       abcdefgh
    """)
  end
end
