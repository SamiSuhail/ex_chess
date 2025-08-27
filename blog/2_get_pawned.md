# 2 - Get pawned
This blog post is part of a series that will be walking you through the process of building a production-ready chess application using Elixir.

Each blog post is a separate PR in [the github repository](https://github.com/SamiSuhail/ex_chess), and each section of the blog post with the relevant code is a commit in that PR.

To look at the code, check out [this PR](https://github.com/SamiSuhail/ex_chess/pull/2).

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

## Agenda
Today sounds like it's all about pawns but it really isn't. If phase one was us laying the foundations, phase two is all about future-proofing. Pawns are just one of the things we need in order to achieve that.

- 2.1 - `Game.list_legal_moves(game, from_square)` 
- 2.2 - Extensive testing
- 2.3 - Pawns
  - 2.3.1 - Advancing
  - 2.3.2 - Validation - pawn cannot advance two squares after moving
  - 2.3.3 - Validation - pawn cannot advance if path is blocked
  - 2.3.4 - Taking
  - 2.3.5 - Validation - pawn cannot move diagonally when not taking
- 2.4 - Refactor - Movement types

## 2.1 - `Game.list_legal_moves(game, from_square)`
Most chess apps have some functionality similar to this - you click a piece on the board and the squares it can move to are highlighted. By implementing this early one we ensure it helps shape our design in a way that accomodates it.

### Test
I've added couple of new helper methods. The names are pretty self explanatory. In this case we check that the night on `b1` can move in front the pawns on files `a` and `c`.
```elixir
  test "list legal moves" do
    Arrange.new_game()
    |> Arrange.game_list_legal_moves("b1")
    |> Assert.legal_moves(["a3", "c3"])
  end
```

### Implementation
Thanks to our refactor in the previous, listing the movies is fairly simple. We take all the patterns for a piece, map them to moves, and filter out the invalid ones.

I won't post the changes to the `Arrange` and `Assert` module in here, but you can check them out on the PR linked at the top of the page.

```elixir
  @spec list_legal_moves(t(), Square.t()) :: [Square.t()]
  def list_legal_moves(%__MODULE__{board: board}, from_square = %Square{}) do
    piece = Board.get(board, from_square)

    patterns(piece)
    |> Enum.map(fn {file_shift, rank_shift} ->
      Square.shift(from_square, file_shift, rank_shift)
    end)
    |> Enum.filter(fn to_square ->
      valid_move?(board, piece, Move.new(from_square, to_square))
    end)
  end
```

## 2.2 - Extensive testing
Thanks to the new `Game.list_legal_moves/2` function, it is way easier to test for multiple movement patterns at once. However if we want to make maximal use of it, we're gonna want to also make setting up the board easier by adding a new `Arrange.game_board/2` function.

We will also make use of parameterized testing thanks to `@tag` attributes and for comprehensions.

### Test
If you want to check out the implementation of `Arrange.game_board/2` I invite you to check out the PR linked above. Once that's added in, all below tests should be passing.

```elixir
defmodule ExChessTest.KnightTest do
  use ExUnit.Case
  alias ExChessTest.{Arrange, Assert}

  @scenarios [
    {
      "default",
      """
         abcdefgh
        ----------
      8 |       k| 8
      7 |        | 7
      6 |        | 6
      5 |        | 5
      4 |   N    | 4
      3 |        | 3
      2 |        | 2
      1 |       K| 1
        ----------
         abcdefgh
      """
    },
    {
      "can jump over pieces",
      """
         abcdefgh
        ----------
      8 |       k| 8
      7 |        | 7
      6 |        | 6
      5 |  ppp   | 5
      4 |  pNp   | 4
      3 |  ppp   | 3
      2 |        | 2
      1 |       K| 1
        ----------
         abcdefgh
      """
    },
    {
      "taking",
      """
         abcdefgh
        ----------
      8 |       k| 8
      7 |        | 7
      6 |  p p   | 6
      5 | p   p  | 5
      4 |   N    | 4
      3 | p   p  | 3
      2 |  p p   | 2
      1 |       K| 1
        ----------
         abcdefgh
      """
    },
  ]

  for {scenario_name, board} <- @scenarios do
    @tag board: board
    test "list legal moves - #{scenario_name}", %{board: board} do
      Arrange.new_game()
      |> Arrange.game_board(board)
      |> Arrange.game_list_legal_moves("d4")
      |> Assert.legal_moves(["b3", "b5", "c2", "c6", "e2", "e6", "f3", "f5"])
    end
  end
end

defmodule ExChessTest.KingTest do
  use ExUnit.Case
  alias ExChessTest.{Arrange, Assert}

  @scenarios [
    {
      "default",
      """
         abcdefgh
        ----------
      8 |       k| 8
      7 |        | 7
      6 |        | 6
      5 |        | 5
      4 |   K    | 4
      3 |        | 3
      2 |        | 2
      1 |        | 1
        ----------
         abcdefgh
      """
    },
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
      """
    },
  ]

  for {scenario_name, board} <- @scenarios do
    @tag board: board
    test "list legal moves - #{scenario_name}", %{board: board} do
      Arrange.new_game()
      |> Arrange.game_board(board)
      |> Arrange.game_list_legal_moves("d4")
      |> Assert.legal_moves(["c3", "c4", "c5", "d3", "d5", "e3", "e4", "e5"])
    end
  end
end
```

## 2.3 - Pawns
For this first implementation of the pawns we are going to ignore special moves like en passant and promotion. We're instead going to implement just the basic set of moves: advancing one or two squares, and taking diagonally.

### 2.3.1 - Advancing
The very first iteration will just make sure the pawns can advance one or two squares.

#### Test
```elixir
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
end
```

#### Implementation

All that's needed is to extend `Game.patterns/1`.
```elixir
defmodule ExChess.Game do
  ...
  @pawn_patterns_white [
    {0, 1},
    {0, 2},
  ]

  @pawn_patterns_black [
    {0, -1},
    {0, -2},
  ]
  ...
  defp patterns(%Piece{type: :p, color: :white}), do: @pawn_patterns_white
  defp patterns(%Piece{type: :p, color: :black}), do: @pawn_patterns_black
  ...
end
```

### 2.3.2 - Validation - pawn cannot advance two squares after moving

#### Test
We're going to check that both black and white can no longer advance two squares with a pawn once it's moved from the starting rank.

For the second assertion, we still make sure to first move a white piece. We don't want old tests breaking later when we add turn validation.
```elixir
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
```

#### Implementation
A very simple addition to `Game.valid_move?/3`. We make sure to now also check piece-specific rules. We're also adding an extra function head - if a piece does not have any specific rules specified, then the move is considered valid.

```diff
  defp valid_move?(board = %{}, piece = %Piece{}, move = %Move{}) do
    target_piece = Board.get(board, move.to)

    not Piece.same_color?(piece, target_piece) and
      patterns(piece)
-     |> valid_move_pattern?(move)
+     |> valid_move_pattern?(move) and
+     piece_rules_followed?(piece, move)
  end
```
```elixir
  defp piece_rules_followed?(%Piece{type: :p}, move = %Move{}) do
    (move.to.rank - move.from.rank) not in [-2, 2] or
      move.from.rank in [1, 6]
  end

  defp piece_rules_followed?(%Piece{}, %Move{}), do: true
```
All we need to do is ensure that either we are not moving two ranks, or we are on the starting rank. And just like that, our tests are now passing.



  - 2.3.3 - Validation - pawn cannot advance if path is blocked
  - 2.3.4 - Taking
  - 2.3.5 - Validation - pawn cannot move diagonally when not taking
- 2.4 - Refactor - Movement types