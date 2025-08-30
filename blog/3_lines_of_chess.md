# 3 - Lines of chess
This blog post is part of a series that will be walking you through the process of building a production-ready chess application using Elixir.

Each blog post is a separate PR in [the github repository](https://github.com/SamiSuhail/ex_chess), and each section of the blog post with the relevant code is a commit in that PR.

To look at the code, check out [this PR](https://github.com/SamiSuhail/ex_chess/pull/3).

Check out the [introductory post](TODO).

#### IMPORTANT
This series is a practical one. For each step, I will start by giving you the tests. Always start by making the tests pass on your own. After making them pass, check if there is anything you want to refactor. Only once you're done with that should you look at my implementations. Otherwise the posts will be of limited value to you.

### Completed work
- 1 - [Pieces and a board](TODO)
  - 1.0 - Board representation
  - 1.1 - `Game.new()`
  - 1.2 - `Game.move(game, move)`
  - 1.3 - Validation - movement patterns (knight, king)
  - 1.4 - Validation - cannot take own piece
  - 1.5 - Validation - cannot move empty square
  - 1.6 - Validation - cannot move outside board bounds
- 2 - [Get pawned](TODO)
  - 2.1 - `Game.list_legal_moves(game, from_square)` 
  - 2.2 - Extensive testing
  - 2.3 - Pawns
    - 2.3.1 - Advancing
    - 2.3.2 - Validation - pawn cannot advance two squares after moving
    - 2.3.3 - Validation - pawn cannot advance if path is blocked
    - 2.3.4 - Taking
    - 2.3.5 - Validation - pawn cannot move diagonally when not taking
    - 2.3.6 - Test - `list_legal_moves`

## Agenda
Today is about finishing up the basic piece movements. The last three pieces all have linear moves, which is why it makes sense to implement them together.

- 3.1 - Rooks
- 3.2 - Bishops
- 3.3 - Queens
- 3.4 - Validation - cannot move when path is blocked

## 3.1 - Rooks
We'll start with the rooks. We need to make sure those can move in straight lines.

### Test
You'll notice I'm adding a couple of new helper functions in order to make the tests more readable. I won't share the code for that, but feel free to look at it on [my PR](https://github.com/SamiSuhail/ex_chess/pull/3).

All we're doing here is making sure the rooks of both players are able to move in straight lines on the board.
```elixir
defmodule ExChessTest.RookTest do
  use ExUnit.Case
  alias ExChessTest.{Arrange, Assert}

  test "list_legal_moves" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k       | 8
      7 |p       | 7
      6 |        | 6
      5 |    r   | 5
      4 |   R    | 4
      3 |        | 3
      2 |P       | 2
      1 |K       | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_list_legal_moves(game, "d4")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | k       [ ]            | 8
    7 | p       [ ]            | 7
    6 |         [ ]            | 6
    5 |         [ ] r          | 5
    4 |[ ][ ][ ] R [ ][ ][ ][ ]| 4
    3 |         [ ]            | 3
    2 | P       [ ]            | 2
    1 | K       [ ]            | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_list_legal_moves("e5")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | k          [ ]         | 8
    7 | p          [ ]         | 7
    6 |            [ ]         | 6
    5 |[ ][ ][ ][ ] r [ ][ ][ ]| 5
    4 |          R [ ]         | 4
    3 |            [ ]         | 3
    2 | P          [ ]         | 2
    1 | K          [ ]         | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)
  end
end
```

### Implementation
All we need to do is add the rook patterns. I'll do that by representing all four directions as `{file_direction, rank_direction}` tuples. We can then get `1..7` as distances in order to get 7 squares in each direction. This is the full range of motion of the rook. 

```elixir
defmodule ExChess.Game do
  ...
  @rook_patterns [
                   {0, 1},
                   {1, 0},
                   {0, -1},
                   {-1, 0},
                 ]
                 |> Enum.flat_map(fn {file_direction, rank_direction} ->
                   1..7
                   |> Enum.map(fn distance ->
                     {file_direction * distance, rank_direction * distance}
                   end)
                 end)
  ...
  defp patterns(%Piece{type: :r}), do: @rook_patterns
  ...
end
```

And like that our test is now passing. Let's do the same for bishops and queens.

## 3.2 - Bishops
Very similar to the rooks, with the only difference being that they go diagonally instead of straight lines.

### Test
```elixir
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
end
```

### Implementation
```elixir
defmodule ExChess.Game do
  ...
  @bishop_patterns [
                     {1, 1},
                     {1, -1},
                     {-1, 1},
                     {-1, -1},
                   ]
                   |> Enum.flat_map(fn {file_direction, rank_direction} ->
                     1..7
                     |> Enum.map(fn distance ->
                       {file_direction * distance, rank_direction * distance}
                     end)
                   end)
  ...
  defp patterns(%Piece{type: :b}), do: @bishop_patterns
  ...
end
```