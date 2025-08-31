defmodule ExChessTest.QueenTest do
  use ExUnit.Case
  alias ExChessTest.{Arrange, Assert}

  test "list_legal_moves" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |       k| 8
      7 |        | 7
      6 |   q    | 6
      5 |        | 5
      4 |    Q   | 4
      3 |        | 3
      2 |        | 2
      1 |K       | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_list_legal_moves(game, "e4")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 |[ ]         [ ]       k | 8
    7 |   [ ]      [ ]      [ ]| 7
    6 |      [ ] q [ ]   [ ]   | 6
    5 |         [ ][ ][ ]      | 5
    4 |[ ][ ][ ][ ] Q [ ][ ][ ]| 4
    3 |         [ ][ ][ ]      | 3
    2 |      [ ]   [ ]   [ ]   | 2
    1 | K [ ]      [ ]      [ ]| 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_list_legal_moves("d6")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 |   [ ]   [ ]   [ ]    k | 8
    7 |      [ ][ ][ ]         | 7
    6 |[ ][ ][ ] q [ ][ ][ ][ ]| 6
    5 |      [ ][ ][ ]         | 5
    4 |   [ ]   [ ] Q [ ]      | 4
    3 |[ ]      [ ]      [ ]   | 3
    2 |         [ ]         [ ]| 2
    1 | K       [ ]            | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)
  end

  test "validation - cannot move when path is blocked (white)" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k       | 8
      7 |        | 7
      6 | p p p  | 6
      5 |        | 5
      4 | P Q p  | 4
      3 |        | 3
      2 | P P P  | 2
      1 |K       | 1
        ----------
         abcdefgh
      """)

    Arrange.game_list_legal_moves(game, "d4")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | k                      | 8
    7 |                        | 7
    6 |   [p]   [p]   [p]      | 6
    5 |      [ ][ ][ ]         | 5
    4 |    P [ ] Q [ ][p]      | 4
    3 |      [ ][ ][ ]         | 3
    2 |    P     P     P       | 2
    1 | K                      | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)
  end

  test "validation - cannot move when path is blocked (black)" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k       | 8
      7 |        | 7
      6 | p p p  | 6
      5 |        | 5
      4 | P q p  | 4
      3 |        | 3
      2 | P P P  | 2
      1 |K       | 1
        ----------
         abcdefgh
      """)

    Arrange.game_list_legal_moves(game, "d4")

    Arrange.game_list_legal_moves(game, "d4")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | k                      | 8
    7 |                        | 7
    6 |    p     p     p       | 6
    5 |      [ ][ ][ ]         | 5
    4 |   [P][ ] q [ ] p       | 4
    3 |      [ ][ ][ ]         | 3
    2 |   [P]   [P]   [P]      | 2
    1 | K                      | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)
  end
end
