defmodule ExChessTest.GameTest do
  use ExUnit.Case
  alias ExChessTest.{Arrange, Assert}

  test "new game" do
    Arrange.new_game()
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |rnbqkbnr| 8
    7 |pppppppp| 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |        | 3
    2 |PPPPPPPP| 2
    1 |RNBQKBNR| 1
      ----------
       abcdefgh
    """)
  end
end
