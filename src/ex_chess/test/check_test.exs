defmodule ExChessTest.CheckTest do
  use ExUnit.Case
  alias ExChessTest.{Arrange, Assert}

  test "validation - check must be respected" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k       | 8
      7 |p      R| 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |P      r| 2
      1 |K       | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("h2h1")
    |> Arrange.game_move("a2a3")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(game, "h7h8")
    |> Arrange.game_move("a7a6")
    |> Assert.invalid_move()
  end

  test "validation - king cannot move into check" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k       | 8
      7 |p      R| 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |P      r| 2
      1 |K       | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_move(game, "a1b2")
    |> Assert.invalid_move()

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("a8b7")
    |> Assert.invalid_move()
  end

  test "validation - cannot move pinned piece" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |kr     R| 8
      7 |        | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |        | 2
      1 |KR     r| 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_move(game, "b1b2")
    |> Assert.invalid_move()

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("b8b7")
    |> Assert.invalid_move()
  end

  test "validation - revealed checks should be respected" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k     NR| 8
      7 |p       | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |P       | 2
      1 |K     nr| 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("g1h3")
    |> Arrange.game_move("a2a3")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(game, "g8h6")
    |> Arrange.game_move("a7a6")
    |> Assert.invalid_move()
  end

  test "taking the piece that is threatening your king is allowed" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k      R| 8
      7 |p       | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |P       | 2
      1 |K      r| 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_move(game, "h8h1")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |k       | 8
    7 |p       | 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |        | 3
    2 |P       | 2
    1 |K      R| 1
      ----------
       abcdefgh
    """)

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("h1h8")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |k      r| 8
    7 |p       | 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |        | 3
    2 |P       | 2
    1 |K       | 1
      ----------
       abcdefgh
    """)
  end
end
