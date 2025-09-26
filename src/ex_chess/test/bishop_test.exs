defmodule ExChessTest.BishopTest do
  use ExUnit.Case
  alias ExChessTest.{Arrange, Assert}

  test "list_legal_moves" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |    k   | 8
      7 |    p   | 7
      6 |        | 6
      5 |    b   | 5
      4 |    B   | 4
      3 |        | 3
      2 |    P   | 2
      1 |    K   | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_list_legal_moves(game, "e4")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 |[ ]          k          | 8
    7 |   [ ]       p       [ ]| 7
    6 |      [ ]         [ ]   | 6
    5 |         [ ] b [ ]      | 5
    4 |             B          | 4
    3 |         [ ]   [ ]      | 3
    2 |      [ ]    P    [ ]   | 2
    1 |   [ ]       K       [ ]| 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_list_legal_moves("e5")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 |   [ ]       k       [ ]| 8
    7 |      [ ]    p    [ ]   | 7
    6 |         [ ]   [ ]      | 6
    5 |             b          | 5
    4 |         [ ] B [ ]      | 4
    3 |      [ ]         [ ]   | 3
    2 |   [ ]       P       [ ]| 2
    1 |[ ]          K          | 1
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
      6 | p   p  | 6
      5 |        | 5
      4 |   B    | 4
      3 |        | 3
      2 | P   P  | 2
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
    6 |   [p]         [p]      | 6
    5 |      [ ]   [ ]         | 5
    4 |          B             | 4
    3 |      [ ]   [ ]         | 3
    2 |    P           P       | 2
    1 | K                      | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)
  end

  test "validation - cannot move when path is blocked (black)" do
    game =
      Arrange.new_game()
      |> Arrange.game_turn(:black)
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k       | 8
      7 |        | 7
      6 | p   p  | 6
      5 |        | 5
      4 |   b    | 4
      3 |        | 3
      2 | P   P  | 2
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
    6 |    p           p       | 6
    5 |      [ ]   [ ]         | 5
    4 |          b             | 4
    3 |      [ ]   [ ]         | 3
    2 |   [P]         [P]      | 2
    1 | K                      | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)
  end
end
