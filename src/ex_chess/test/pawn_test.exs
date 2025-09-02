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

  test "advance (list_legal_moves) (white)" do
    Arrange.new_game()
    |> Arrange.game_list_legal_moves("a2")
    |> Assert.legal_moves(["a3", "a4"])
  end

  test "advance (list_legal_moves) (black)" do
    Arrange.new_game()
    |> Arrange.game_move("a2a4")
    |> Arrange.game_list_legal_moves("a7")
    |> Assert.legal_moves(["a6", "a5"])
  end

  @validation_after_moving_board Arrange.new_game()
                                 |> Arrange.game_move("a2a3")
                                 |> Arrange.game_move("a7a6")

  test "validation - pawn cannot advance two squares after moving" do
    # white
    Arrange.game_move(@validation_after_moving_board, "a3a5")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(@validation_after_moving_board, "b2b3")
    |> Arrange.game_move("a6a4")
    |> Assert.invalid_move()
  end

  test "validation - pawn cannot advance two squares after moving (list_legal_moves)" do
    # white
    Arrange.game_list_legal_moves(@validation_after_moving_board, "a3")
    |> Assert.legal_moves(["a4"])

    # black
    Arrange.game_move(@validation_after_moving_board, "b2b3")
    |> Arrange.game_list_legal_moves("a6")
    |> Assert.legal_moves(["a5"])
  end

  @validation_cannot_advance_board Arrange.new_game()
                                   |> Arrange.game_board("""
                                      abcdefgh
                                     ----------
                                   8 |rnbqkbnr| 8
                                   7 |ppppppp | 7
                                   6 |P       | 6
                                   5 |        | 5
                                   4 |        | 4
                                   3 |       p| 3
                                   2 | PPPPPPP| 2
                                   1 |RNBQKBNR| 1
                                     ----------
                                      abcdefgh
                                   """)

  test "validation - pawn cannot advance when path is blocked" do
    # white
    Arrange.game_move(@validation_cannot_advance_board, "h2h3")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(@validation_cannot_advance_board, "b2b3")
    |> Arrange.game_move("a7a6")
    |> Assert.invalid_move()
  end

  test "validation - pawn cannot advance when path is blocked (list_legal_moves)" do
    # white
    Arrange.game_list_legal_moves(@validation_cannot_advance_board, "h2")
    |> Assert.legal_moves([])

    # black
    Arrange.game_move(@validation_cannot_advance_board, "b2b3")
    |> Arrange.game_list_legal_moves("a7")
    |> Assert.legal_moves([])
  end

  @validation_cannot_advance_two_squares_board Arrange.new_game()
                                               |> Arrange.game_board("""
                                                  abcdefgh
                                                 ----------
                                               8 |rnbqkbnr| 8
                                               7 |ppppp p | 7
                                               6 |P       | 6
                                               5 |  P     | 5
                                               4 |     p  | 4
                                               3 |       p| 3
                                               2 | P PPPPP| 2
                                               1 |RNBQKBNR| 1
                                                 ----------
                                                  abcdefgh
                                               """)
  test "validation - pawn cannot advance two ranks when square in front is occupied" do
    # white
    Arrange.game_move(@validation_cannot_advance_two_squares_board, "h2h4")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(@validation_cannot_advance_two_squares_board, "b2b3")
    |> Arrange.game_move("a7a5")
    |> Assert.invalid_move()
  end

  test "validation - pawn cannot advance two ranks when square in front is occupied (list_legal_moves)" do
    # white
    Arrange.game_list_legal_moves(@validation_cannot_advance_two_squares_board, "h2")
    |> Assert.legal_moves([])

    # black
    Arrange.game_move(@validation_cannot_advance_two_squares_board, "b2b3")
    |> Arrange.game_list_legal_moves("a7")
    |> Assert.legal_moves([])
  end

  test "validation - pawn cannot advance two ranks when square two ranks in front is occupied" do
    # white
    Arrange.game_move(@validation_cannot_advance_two_squares_board, "f2f4")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(@validation_cannot_advance_two_squares_board, "b2b3")
    |> Arrange.game_move("c7c5")
    |> Assert.invalid_move()
  end

  test "validation - pawn cannot advance two ranks when square two ranks in front is occupied (list_legal_moves)" do
    # white
    Arrange.game_list_legal_moves(@validation_cannot_advance_two_squares_board, "f2")
    |> Assert.legal_moves(["f3"])

    # black
    Arrange.game_move(@validation_cannot_advance_two_squares_board, "b2b3")
    |> Arrange.game_list_legal_moves("c7")
    |> Assert.legal_moves(["c6"])
  end

  test "taking" do
    Arrange.new_game()
    |> Arrange.game_board("""
       abcdefgh
      ----------
    8 |rnbqkbnr| 8
    7 |pppp ppp| 7
    6 |   P    | 6
    5 |        | 5
    4 |        | 4
    3 |    p   | 3
    2 |PPP PPPP| 2
    1 |RNBQKBNR| 1
      ----------
       abcdefgh
    """)
    |> Arrange.game_move("f2e3")
    |> Arrange.game_move("c7d6")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |rnbqkbnr| 8
    7 |pp p ppp| 7
    6 |   p    | 6
    5 |        | 5
    4 |        | 4
    3 |    P   | 3
    2 |PPP P PP| 2
    1 |RNBQKBNR| 1
      ----------
       abcdefgh
    """)
  end

  test "taking (list_legal_moves)" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |    k   | 8
      7 |    p   | 7
      6 |   PPP  | 6
      5 |        | 5
      4 |        | 4
      3 |   ppp  | 3
      2 |    P   | 2
      1 |    K   | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_list_legal_moves(game, "e2")
    |> Assert.legal_moves(["f3", "d3"])

    # black
    Arrange.game_move(game, "e1f1")
    |> Arrange.game_list_legal_moves("e7")
    |> Assert.legal_moves(["f6", "d6"])
  end

  test "validation - pawn cannot take empty squares" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
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

    # white
    Arrange.game_move(game, "d2c3")
    |> Assert.invalid_move()

    Arrange.game_move(game, "d2e3")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(game, "d2d3")
    |> Arrange.game_move("d7c6")
    |> Assert.invalid_move()

    Arrange.game_move(game, "d2d3")
    |> Arrange.game_move("d7e6")
    |> Assert.invalid_move()
  end

  test "en passant" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |   k    | 8
      7 |   p    | 7
      6 |        | 6
      5 |  P     | 5
      4 |    p   | 4
      3 |        | 3
      2 |   P    | 2
      1 |   K    | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("d7d5")
    |> Arrange.game_move("c5d6")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |   k    | 8
    7 |        | 7
    6 |   P    | 6
    5 |        | 5
    4 |    p   | 4
    3 |        | 3
    2 |   P    | 2
    1 |   K    | 1
      ----------
       abcdefgh
    """)

    # black
    Arrange.game_move(game, "d2d4")
    |> Arrange.game_move("e4d3")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |   k    | 8
    7 |   p    | 7
    6 |        | 6
    5 |  P     | 5
    4 |        | 4
    3 |   p    | 3
    2 |        | 2
    1 |   K    | 1
      ----------
       abcdefgh
    """)
  end

  test "validation - cannot en passant if last move was not two square advance" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |   k    | 8
      7 |   p    | 7
      6 |        | 6
      5 |  P     | 5
      4 |    p   | 4
      3 |        | 3
      2 |   P    | 2
      1 |   K    | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("d7d6")
    |> Arrange.game_turn(:black)
    |> Arrange.game_move("d6d5")
    |> Arrange.game_move("c5d6")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(game, "d2d3")
    |> Arrange.game_turn(:white)
    |> Arrange.game_move("d3d4")
    |> Arrange.game_move("e4d3")
    |> Assert.invalid_move()
  end

  test "validation - cannot en passant if two square advance was two moves ago" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |   k    | 8
      7 |   p    | 7
      6 |        | 6
      5 |  P     | 5
      4 |    p   | 4
      3 |        | 3
      2 |   P    | 2
      1 |   K    | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("d7d5")
    |> Arrange.game_turn(:black)
    |> Arrange.game_move("d8c8")
    |> Arrange.game_move("c5d6")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(game, "d2d4")
    |> Arrange.game_turn(:white)
    |> Arrange.game_move("d1c1")
    |> Arrange.game_move("e4d3")
    |> Assert.invalid_move()
  end

  test "validation - cannot en passant if not on correct rank" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |   k    | 8
      7 |   pp   | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |  PP    | 2
      1 |   K    | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("d7d5")
    |> Arrange.game_move("c2d3")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(game, "d2d4")
    |> Arrange.game_move("e7d6")
    |> Assert.invalid_move()
  end

  test "promotion" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k       | 8
      7 |p  P    | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |P  p    | 2
      1 |K       | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_promote(game, "d7d8", :b)
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |k  B    | 8
    7 |p       | 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |        | 3
    2 |P  p    | 2
    1 |K       | 1
      ----------
       abcdefgh
    """)

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_promote("d2d1", :b)
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |k       | 8
    7 |p  P    | 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |        | 3
    2 |P       | 2
    1 |K  b    | 1
      ----------
       abcdefgh
    """)
  end

  test "validation - cannot advance to final rank without promoting" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k       | 8
      7 |p  P    | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |P  p    | 2
      1 |K       | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_move(game, "d7d8")
    |> Assert.invalid_move()

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("d2d1")
    |> Assert.invalid_move()
  end

  test "validation - cannot promote to king or pawn" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k       | 8
      7 |p  P    | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |P  p    | 2
      1 |K       | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_promote(game, "d7d8", :k)
    |> Assert.invalid_move()

    Arrange.game_promote(game, "d7d8", :p)
    |> Assert.invalid_move()

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_promote("d2d1", :k)
    |> Assert.invalid_move()

    Arrange.game_turn(game, :black)
    |> Arrange.game_promote("d2d1", :p)
    |> Assert.invalid_move()
  end

  test "validation - pawn cannot promote if not on final square" do
    # white
    Arrange.new_game()
    |> Arrange.game_promote("a2a3", :q)
    |> Assert.invalid_move()

    # black
    Arrange.new_game()
    |> Arrange.game_move("a2a3")
    |> Arrange.game_promote("a7a6", :q)
    |> Assert.invalid_move()
  end
end
