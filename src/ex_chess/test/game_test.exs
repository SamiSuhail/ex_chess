defmodule ExChessTest.GameTest do
  use ExUnit.Case
  alias ExChessTest.{Arrange, Assert}
  doctest ExChess
  doctest ExChess.Game
  doctest ExChess.Visualization
  doctest ExChess.Board
  doctest ExChess.Move
  doctest ExChess.Square
  doctest ExChess.Piece

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

  test "invalid move - cannot move empty square" do
    Arrange.new_game()
    |> Arrange.game_move("b3b4")
    |> Assert.invalid_move()
  end

  test "invalid move - cannot move outside board bounds" do
    Arrange.new_game()
    |> Arrange.game_move("b1d0")
    |> Assert.invalid_move()
  end

  test "invalid move - cannot move same color piece twice in a row" do
    Arrange.new_game()
    |> Arrange.game_move("a2a4")
    |> Arrange.game_move("b2b4")
    |> Assert.invalid_move()
  end

  test "list legal moves" do
    Arrange.new_game()
    |> Arrange.game_list_legal_moves("b1")
    |> Assert.legal_moves(["a3", "c3"])
  end

  test "fullmove number increments" do
    Arrange.new_game()
    |> Assert.fullmove_number(1)
    |> Arrange.game_move("a2a4")
    |> Assert.fullmove_number(1)
    |> Arrange.game_move("a7a5")
    |> Assert.fullmove_number(2)
    |> Arrange.game_move("b2b4")
    |> Assert.fullmove_number(2)
    |> Arrange.game_move("b7b5")
    |> Assert.fullmove_number(3)
  end
end
