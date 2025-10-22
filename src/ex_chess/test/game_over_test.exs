defmodule ExChessTest.GameOverTest do
  use ExUnit.Case
  alias ExChessTest.{Arrange, Assert}

  test "checkmate" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |       k| 8
      7 | R      | 7
      6 |R       | 6
      5 |pp      | 5
      4 |PP      | 4
      3 |r       | 3
      2 | r      | 2
      1 |       K| 1
        ----------
         abcdefgh
      """)

    Arrange.game_move(game, "a6a8")
    |> Assert.checkmate(:white)

    Arrange.game_turn(game, :black)
    |> Arrange.game_move("a3a1")
    |> Assert.checkmate(:black)
  end

  test "resignation" do
    Arrange.new_game()
    |> Arrange.resign()
    |> Assert.resignation(:black)

    Arrange.new_game()
    |> Arrange.game_move("a2a3")
    |> Arrange.resign()
    |> Assert.resignation(:white)
  end

  test "validation - cannot move after resignation" do
    Arrange.new_game()
    |> Arrange.resign()
    |> Arrange.game_move("a2a3")
    |> Assert.invalid_move()

    Arrange.new_game()
    |> Arrange.game_move("a2a3")
    |> Arrange.resign()
    |> Arrange.game_move("a7a6")
    |> Assert.invalid_move()
  end

  test "stalemate" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |        | 8
      7 |        | 7
      6 |        | 6
      5 |        | 5
      4 |p       | 4
      3 |    p   | 3
      2 |P   Pp p| 2
      1 |     K k| 1
        ----------
         abcdefgh
      """)

    Arrange.game_move(game, "a2a3")
    |> Assert.stalemate()

    Arrange.game_turn(game, :black)
    |> Arrange.game_move("a4a3")
    |> Assert.stalemate()
  end

  test "insufficient material" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |        | 8
      7 |        | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |       K| 3
      2 |r      b| 2
      1 |K      k| 1
        ----------
         abcdefgh
      """)

    Arrange.game_move(game, "a1a2")
    |> Assert.insufficient_material()
  end

  test "threefold repetition" do
    Arrange.new_game()
    |> Arrange.game_moves("""
    b1c3 b8c6
    c3b1 c6b8
    b1c3 b8c6
    c3b1 c6b8
    """)
    |> Arrange.claim_draw()
    |> Assert.threefold_repetition()
  end

  test "fivefold repetition" do
    Arrange.new_game()
    |> Arrange.game_moves("""
    b1c3 b8c6
    c3b1 c6b8
    b1c3 b8c6
    c3b1 c6b8
    b1c3 b8c6
    c3b1 c6b8
    b1c3 b8c6
    c3b1 c6b8
    """)
    |> Assert.fivefold_repetition()
  end

  test "validation - cannot move if game completed" do
    Arrange.new_game()
    |> Arrange.game_moves("""
    b1c3 b8c6
    c3b1 c6b8
    b1c3 b8c6
    c3b1 c6b8
    b1c3 b8c6
    c3b1 c6b8
    b1c3 b8c6
    c3b1 c6b8
    b1c3
    """)
    |> Assert.invalid_move()
  end

  test "50 move rule" do
    fifty_move_rule_game()
    |> Arrange.claim_draw()
    |> Assert.fifty_move_rule()
  end

  test "75 move rule" do
    seventy_five_move_rule_game()
    |> Assert.seventy_five_move_rule()
  end

  test "validation - cannot claim draw before 50 move rule applies" do
    Arrange.new_game()
    |> Arrange.claim_draw()
    |> Assert.invalid_move()
  end

  test "validation - cannot claim draw when halfclock reset" do
    fifty_move_rule_game()
    |> Arrange.game_move("h2h3")
    |> Arrange.claim_draw()
    |> Assert.invalid_move()
  end

  # this sequence makes the kings do two loops around the edges of the board and end up in the same position
  defp fifty_move_rule_game() do
    Arrange.new_game()
    |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |n      k| 8
      7 |p       | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |       P| 2
      1 |K      N| 1
        ----------
         abcdefgh
    """)
    |> Arrange.game_moves("""
    a1b1 h8g8
    b1c1 g8f8
    c1d1 f8e8
    d1e1 e8d8
    e1f1 d8c8
    f1g1 c8b8
    g1g2 b8b7
    g2h3 b7a6
    h3h4 a6a5
    h4h5 a5a4
    h5h6 a4a3
    h6h7 a3a2
    h7h8 a2a1
    h8g8 a1b1
    g8f8 b1c1
    f8e8 c1d1
    e8d8 d1e1
    d8c8 e1f1
    c8b8 f1g1
    b8b7 g1g2
    b7a6 g2h3
    a6a5 h3h4
    a5a4 h4h5
    a4a3 h5h6
    a3a2 h6h7
    a2a1 h7h8
    a1b1 h8g8
    b1c1 g8f8
    c1d1 f8e8
    d1e1 e8d8
    e1f1 d8c8
    f1g1 c8b8
    g1g2 b8b7
    g2h3 b7a6
    h3h4 a6a5
    h4h5 a5a4
    h5h6 a4a3
    h6h7 a3a2
    h7h8 a2a1
    h8g8 a1b1
    g8f8 b1c1
    f8e8 c1d1
    e8d8 d1e1
    d8c8 e1f1
    c8b8 f1g1
    b8b7 g1g2
    b7a6 g2h3
    a6a5 h3h4
    a5a4 h4h5
    a4a3 h5h6
    a3a2 h6h7
    a2a1 h7h8
    """)
  end

  defp seventy_five_move_rule_game() do
    Arrange.new_game()
    |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |n      k| 8
      7 |p       | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |       P| 2
      1 |K      N| 1
        ----------
         abcdefgh
    """)
    |> Arrange.game_moves("""
    a1b1 h8g8
    b1c1 g8f8
    c1d1 f8e8
    d1e1 e8d8
    e1f1 d8c8
    f1g1 c8b8
    g1g2 b8b7
    g2h3 b7a6
    h3h4 a6a5
    h4h5 a5a4
    h5h6 a4a3
    h6h7 a3a2
    h7h8 a2a1
    h8g8 a1b1
    g8f8 b1c1
    f8e8 c1d1
    e8d8 d1e1
    d8c8 e1f1
    c8b8 f1g1
    b8b7 g1g2
    b7a6 g2h3
    a6a5 h3h4
    a5a4 h4h5
    a4a3 h5h6
    a3a2 h6h7
    a2a1 h7h8
    a1b1 h8g8
    b1c1 g8f8
    c1d1 f8e8
    d1e1 e8d8
    e1f1 d8c8
    f1g1 c8b8
    g1g2 b8b7
    g2h3 b7a6
    h3h4 a6a5
    h4h5 a5a4
    h5h6 a4a3
    h6h7 a3a2
    h7h8 a2a1
    h8g8 a1b1
    g8f8 b1c1
    f8e8 c1d1
    e8d8 d1e1
    d8c8 e1f1
    c8b8 f1g1
    b8b7 g1g2
    b7a6 g2h3
    a6a5 h3h4
    a5a4 h4h5
    a4a3 h5h6
    a3a2 h6h7
    a2a1 h7h8
    a1b1 h8g8
    b1c1 g8f8
    c1d1 f8e8
    d1e1 e8d8
    e1f1 d8c8
    f1g1 c8b8
    g1g2 b8b7
    g2h3 b7a6
    h3h4 a6a5
    h4h5 a5a4
    h5h6 a4a3
    h6h7 a3a2
    h7h8 a2a1
    h8g8 a1b1
    g8f8 b1c1
    f8e8 c1d1
    e8d8 d1e1
    d8c8 e1f1
    c8b8 f1g1
    b8b7 g1g2
    b7a6 g2h3
    a6a5 h3h4
    a5a4 h4h5
    """)
  end
end
