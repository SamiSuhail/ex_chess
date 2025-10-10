defmodule ExChessTest.KingTest do
  use ExUnit.Case
  alias ExChessTest.{Arrange, Assert}

  @scenarios [
    # {
    #   "default",
    #   """
    #      abcdefgh
    #     ----------
    #   8 |       k| 8
    #   7 |        | 7
    #   6 |        | 6
    #   5 |        | 5
    #   4 |   K    | 4
    #   3 |        | 3
    #   2 |P       | 2
    #   1 |        | 1
    #     ----------
    #      abcdefgh
    #   """,
    #   ["c3", "c4", "c5", "d3", "d5", "e3", "e4", "e5"]
    # },
    {
      "taking",
      """
         abcdefgh
        ----------
      8 |       k| 8
      7 |        | 7
      6 |        | 6
      5 |  ppp   | 5
      4 |   K    | 4
      3 |  ppp   | 3
      2 |        | 2
      1 |        | 1
        ----------
         abcdefgh
      """,
      ["c3", "c5", "d3", "d5", "e3", "e5"]
    },
  ]

  for {scenario_name, board, expected_legal_moves} <- @scenarios do
    @tag board: board
    @tag expected_legal_moves: expected_legal_moves
    test "list legal moves - #{scenario_name}", %{
      board: board,
      expected_legal_moves: expected_legal_moves,
    } do
      Arrange.new_game()
      |> Arrange.game_board(board)
      |> Arrange.game_list_legal_moves("d4")
      |> Assert.legal_moves(expected_legal_moves)
    end
  end

  test "castling" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |r   k  r| 8
      7 |        | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |        | 2
      1 |R   K  R| 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_list_legal_moves(game, "e1")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r           k        r | 8
    7 |                        | 7
    6 |                        | 6
    5 |                        | 5
    4 |                        | 4
    3 |                        | 3
    2 |         [ ][ ][ ]      | 2
    1 | R    [ ][ ] K [ ][ ] R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)

    Arrange.game_move(game, "e1c1")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |r   k  r| 8
    7 |        | 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |        | 3
    2 |        | 2
    1 |  KR   R| 1
      ----------
       abcdefgh
    """)

    Arrange.game_move(game, "e1g1")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |r   k  r| 8
    7 |        | 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |        | 3
    2 |        | 2
    1 |R    RK | 1
      ----------
       abcdefgh
    """)

    # black
    game = Arrange.game_turn(game, :black)

    Arrange.game_list_legal_moves(game, "e8")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r    [ ][ ] k [ ][ ] r | 8
    7 |         [ ][ ][ ]      | 7
    6 |                        | 6
    5 |                        | 5
    4 |                        | 4
    3 |                        | 3
    2 |                        | 2
    1 | R           K        R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)

    Arrange.game_move(game, "e8c8")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |  kr   r| 8
    7 |        | 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |        | 3
    2 |        | 2
    1 |R   K  R| 1
      ----------
       abcdefgh
    """)

    Arrange.game_move(game, "e8g8")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |r    rk | 8
    7 |        | 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |        | 3
    2 |        | 2
    1 |R   K  R| 1
      ----------
       abcdefgh
    """)
  end

  test "validation - cannot castle when not on starting position" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |r      r| 8
      7 |    k   | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |    K   | 2
      1 |R      R| 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_list_legal_moves(game, "e2")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r                    r | 8
    7 |             k          | 7
    6 |                        | 6
    5 |                        | 5
    4 |                        | 4
    3 |         [ ][ ][ ]      | 3
    2 |         [ ] K [ ]      | 2
    1 | R       [ ][ ][ ]    R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_list_legal_moves("e7")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r       [ ][ ][ ]    r | 8
    7 |         [ ] k [ ]      | 7
    6 |         [ ][ ][ ]      | 6
    5 |                        | 5
    4 |                        | 4
    3 |                        | 3
    2 |             K          | 2
    1 | R                    R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)
  end

  test "validation - cannot castle if rook has moved" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |r   k  r| 8
      7 |        | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |        | 2
      1 |R   K  R| 1
        ----------
         abcdefgh
      """)

    # white queenside
    Arrange.game_move(game, "a1a2")
    |> Arrange.game_turn(:white)
    |> Arrange.game_move("a2a1")
    |> Arrange.game_turn(:white)
    |> Arrange.game_list_legal_moves("e1")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r           k        r | 8
    7 |                        | 7
    6 |                        | 6
    5 |                        | 5
    4 |                        | 4
    3 |                        | 3
    2 |         [ ][ ][ ]      | 2
    1 | R       [ ] K [ ][ ] R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)

    # white kingside
    Arrange.game_move(game, "h1h2")
    |> Arrange.game_turn(:white)
    |> Arrange.game_move("h2h1")
    |> Arrange.game_turn(:white)
    |> Arrange.game_list_legal_moves("e1")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r           k        r | 8
    7 |                        | 7
    6 |                        | 6
    5 |                        | 5
    4 |                        | 4
    3 |                        | 3
    2 |         [ ][ ][ ]      | 2
    1 | R    [ ][ ] K [ ]    R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)

    # black queenside
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("a8a7")
    |> Arrange.game_turn(:black)
    |> Arrange.game_move("a7a8")
    |> Arrange.game_turn(:black)
    |> Arrange.game_list_legal_moves("e8")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r       [ ] k [ ][ ] r | 8
    7 |         [ ][ ][ ]      | 7
    6 |                        | 6
    5 |                        | 5
    4 |                        | 4
    3 |                        | 3
    2 |                        | 2
    1 | R           K        R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)

    # black kingside
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("h8h7")
    |> Arrange.game_turn(:black)
    |> Arrange.game_move("h7h8")
    |> Arrange.game_turn(:black)
    |> Arrange.game_list_legal_moves("e8")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r    [ ][ ] k [ ]    r | 8
    7 |         [ ][ ][ ]      | 7
    6 |                        | 6
    5 |                        | 5
    4 |                        | 4
    3 |                        | 3
    2 |                        | 2
    1 | R           K        R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)
  end

  test "validation - cannot castle if king has moved" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |r   k  r| 8
      7 |        | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |        | 2
      1 |R   K  R| 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_move(game, "e1e2")
    |> Arrange.game_turn(:white)
    |> Arrange.game_move("e2e1")
    |> Arrange.game_turn(:white)
    |> Arrange.game_list_legal_moves("e1")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r           k        r | 8
    7 |                        | 7
    6 |                        | 6
    5 |                        | 5
    4 |                        | 4
    3 |                        | 3
    2 |         [ ][ ][ ]      | 2
    1 | R       [ ] K [ ]    R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("e8e7")
    |> Arrange.game_turn(:black)
    |> Arrange.game_move("e7e8")
    |> Arrange.game_turn(:black)
    |> Arrange.game_list_legal_moves("e8")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r       [ ] k [ ]    r | 8
    7 |         [ ][ ][ ]      | 7
    6 |                        | 6
    5 |                        | 5
    4 |                        | 4
    3 |                        | 3
    2 |                        | 2
    1 | R           K        R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)
  end

  test "validation - cannot castle if path is not clear" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |rB  k Br| 8
      7 |        | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |        | 2
      1 |Rb  K bR| 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_list_legal_moves(game, "e1")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r  B        k     B  r | 8
    7 |                        | 7
    6 |                        | 6
    5 |                        | 5
    4 |                        | 4
    3 |                        | 3
    2 |         [ ][ ]         | 2
    1 | R  b    [ ] K [ ] b  R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_list_legal_moves("e8")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r  B    [ ] k [ ] B  r | 8
    7 |         [ ][ ]         | 7
    6 |                        | 6
    5 |                        | 5
    4 |                        | 4
    3 |                        | 3
    2 |                        | 2
    1 | R  b        K     b  R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)
  end

  test "validation - cannot castle if square is under attack" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |r   k  r| 8
      7 |        | 7
      6 |    N   | 6
      5 |        | 5
      4 |        | 4
      3 |    n   | 3
      2 |        | 2
      1 |R   K  R| 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_list_legal_moves(game, "e1")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r           k        r | 8
    7 |                        | 7
    6 |             N          | 6
    5 |                        | 5
    4 |                        | 4
    3 |             n          | 3
    2 |         [ ][ ][ ]      | 2
    1 | R           K        R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_list_legal_moves("e8")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r           k        r | 8
    7 |         [ ][ ][ ]      | 7
    6 |             N          | 6
    5 |                        | 5
    4 |                        | 4
    3 |             n          | 3
    2 |                        | 2
    1 | R           K        R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)
  end
end
