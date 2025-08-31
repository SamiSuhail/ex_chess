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

## 3.3 - Queens
Queens are just a bishop-rook hybrid.

### Test
```elixir
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
end
```

### Implementation
```elixir
defmodule ExChess.Game do
  ...
  @queen_patterns Enum.concat(@rook_patterns, @bishop_patterns)  
  ...
  defp patterns(%Piece{type: :q}), do: @queen_patterns
  ...
end
```

## 3.4 - Validation - cannot move when path is blocked
Whenever evaluating whether a move is valid for all three of the pieces we implemented today, we need to check that all the squares between the `from` and `to` squares are empty.

### Test
I will post only the tests I added for the queen. The rook and bishop tests are pretty similar, I recommend you write them yourself, but you can also find them on the PR for today's work. I am adding both ally and enemy pieces on the paths of the queen.

```elixir
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
```

### Implementation
You'll notice that this first implementation I've done is suboptimal (to say the least). When using `Game.list_legal_moves` it will iterate through each square on the piece's patterns, and in the case of today's linear pieces, it will check the path for each one of them. That means that some squares will be checked up to 7 times instead of just once.

I won't bother optimizing it this early on, once we're done implementing everything for the chess game we will run some benchmarks and make changes if needed.

We start by adding a new function head to `Game.piece_rules_followed?` for rooks, bishops and queens. We start by checking the direction of travel - we then start shifting the square in that direction and verify it is empty. Once we've reached the target square, we can conclude the move is valid.
```elixir
defmodule ExChess.Game do
  ...
  defp piece_rules_followed?(
         %Piece{type: piece},
         move = %Move{},
         board = %{}
       )
       when piece in [:r, :b, :q] do
    linear_path_free?(board, move)
  end
  ...
  defp linear_path_free?(board = %{}, %Move{from: from, to: to}) do
    file_direction = linear_direction(from.file, to.file)
    rank_direction = linear_direction(from.rank, to.rank)

    first_square = Square.shift(from, file_direction, rank_direction)

    linear_path_free?(board, first_square, to, file_direction, rank_direction)
  end

  defp linear_direction(from, to) when to < from, do: -1
  defp linear_direction(from, to) when to > from, do: 1
  defp linear_direction(_, _), do: 0

  defp linear_path_free?(board, square, target_square, file_direction, rank_direction) do
    cond do
      Square.same_location?(square, target_square) ->
        true

      not Board.square_empty?(board, square) ->
        false

      true ->
        linear_path_free?(
          board,
          Square.shift(square, file_direction, rank_direction),
          target_square,
          file_direction,
          rank_direction
        )
    end
  end
  ...
end
```

## Conclusion
The last three pieces can now move around on the board, cool - that wasn't too bad.

### Agenda
Next time we'll look at some of the special moves that we've postponed implementing.

- 4 - Chess is special
  - 4.1 - En passant
  - 4.2 - Validation - cannot en passant if pawn did not advance two squares 
  - 4.3 - Promotion
  - 4.4 - Validation - pawn cannot promote if not on final square
  - 4.5 - Castle
  - 4.6 - Validation - cannot castle if path is not clear
  - 4.7 - Validation - cannot castle if rook has moved
  - 4.8 - Validation - cannot castle if king has moved