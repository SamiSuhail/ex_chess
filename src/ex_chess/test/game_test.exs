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

  test "move" do
    Arrange.new_game()
    |> Arrange.game_move("b1c3")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |rnbqkbnr| 8
    7 |pppppppp| 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |  N     | 3
    2 |PPPPPPPP| 2
    1 |R BQKBNR| 1
      ----------
       abcdefgh
    """)
  end

  test "invalid move - movement pattern" do
    Arrange.new_game()
    |> Arrange.game_move("b1b3")
    |> Assert.invalid_move()
  end

  test "invalid move - cannot take own piece" do
    Arrange.new_game()
    |> Arrange.game_move("b1d2")
    |> Assert.invalid_move()
  end
end
