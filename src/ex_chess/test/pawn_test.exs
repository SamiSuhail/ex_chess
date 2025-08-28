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

  test "validation - pawn cannot advance two squares after moving" do
    game =
      Arrange.new_game()
      |> Arrange.game_move("a2a3")
      |> Arrange.game_move("a7a6")

    # white
    Arrange.game_move(game, "a3a5")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(game, "b2b3")
    |> Arrange.game_move("a6a4")
    |> Assert.invalid_move()
  end

  test "validation - pawn cannot advance when path is blocked" do
    game =
      Arrange.new_game()
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

    # white
    Arrange.game_move(game, "h2h3")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(game, "b2b3")
    |> Arrange.game_move("a7a6")
    |> Assert.invalid_move()
  end

  test "validation - pawn cannot advance two ranks when square in front is occupied" do
    game =
      Arrange.new_game()
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

    # white
    Arrange.game_move(game, "h2h4")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(game, "b2b3")
    |> Arrange.game_move("a7a5")
    |> Assert.invalid_move()
  end

  test "validation - pawn cannot advance two ranks when square two ranks in front is occupied" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |rnbqkbnr| 8
      7 |ppppppp | 7
      6 |        | 6
      5 |P       | 5
      4 |       p| 4
      3 |        | 3
      2 | PPPPPPP| 2
      1 |RNBQKBNR| 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_move(game, "h2h4")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(game, "b2b3")
    |> Arrange.game_move("a7a5")
    |> Assert.invalid_move()
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
end
