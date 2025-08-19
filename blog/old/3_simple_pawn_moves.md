# 3 - Simple pawn moves

This blog post is part of a series that will be walking you through the process of building a production-ready chess application using Elixir.

Each blog post is a separate PR in [the github repository](https://github.com/SamiSuhail/ex_chess), and each section of the blog post with the relevant code is a commit in that PR.

To look at the code, check out [this PR](https://github.com/SamiSuhail/ex_chess/pull/2).

### Progress summary
#### 1 - [Pieces and a board](https://github.com/SamiSuhail/ex_chess/blob/main/blog/1_pieces_and_a_board.md)
- 1.1 - The test
- 1.2 - Board representation
- 1.3 - Start a new game
- 1.4 - The test helpers

#### 2 - [Moving knights](https://github.com/SamiSuhail/ex_chess/blob/main/blog/2_moving_knights.md)
- 2.1 - Piece movement
- 2.2 - Validation - No piece found
- 2.3 - Validation - Cannot move outside board bounds
- 2.4 - Validation - Cannot target own piece
- 2.5 - Validation - Must wait for your turn
- 2.6 - Validation - Must be legal move (knight)

### Agenda
Today we're going to implement the simple moves that are allowed for pawns. By simple I mostly mean we're not implementing [en passant](https://en.wikipedia.org/wiki/En_passant)/[promotion](https://en.wikipedia.org/wiki/Promotion_(chess)).

- 3.0 - Refactor - Move knight-specific code
- 3.1 - One square advance
- 3.2 - Two square advance on first move
- 3.3 - Taking
- 3.4 - Validation - Cannot advance when path is not clear

## 3.0 - Refactor - Move knight-specific code
As a starting point, we'll make sure to move any code that is specific to knights in it's own module. That will set us up good for when we're also adding the pawn-specific code.

First we simplify the `LegalMoves` module.
```elixir
defmodule ExChess.LegalMoves do
  alias ExChess.{Board, Square, Piece}
  alias Piece.Knight

  @spec get_all(Board.t(), Square.t(), Piece.t()) :: [Square.t()]
  def get_all(
        board = %{},
        from_square = %Square{},
        piece = %Piece{type: :n}
      ) do
    get_all_basic(board, from_square, piece)
    |> Enum.filter(fn {file, rank} -> Square.valid?(file, rank) end)
    |> Enum.map(fn {file, rank} -> Square.new(file, rank) end)
  end

  defp get_all_basic(_board, from_square, %Piece{type: :n}),
    do: Knight.legal_moves_basic(from_square)
end
```

And we then need to implement `Knight.legal_moves_basic/1`.
```elixir
defmodule ExChess.Piece.Knight do
  alias ExChess.Square

  @patterns_knight [
    {2, -1},
    {2, 1},
    {-2, -1},
    {-2, 1},
    {1, -2},
    {1, 2},
    {-1, -2},
    {-1, 2},
  ]

  @spec legal_moves_basic(Square.t()) :: [{non_neg_integer(), non_neg_integer()}]
  def legal_moves_basic(from_square = %Square{}) do
    @patterns_knight
    |> Enum.map(fn {file_shift, rank_shift} ->
      {
        from_square.file + file_shift,
        from_square.rank + rank_shift
      }
    end)
  end
end
```

I won't paste the diffs, but we're also moving the two knight-specific tests into their own `ExChessTest.KnightTest` module.
The two tests are `"knights can move"` and `"validation - must be legal move (knight)"`.

## 3.1 - One square advance
The first very basic legal moves validation for pawns will always allow the pawn by 1 square, nothing else.

### Tests
```elixir
  test "pawns can move" do
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

  test "validation - must be legal move (pawn)" do
    result =
      Arrange.new_game()
      |> Arrange.game_move("a2b4")

    assert result == {:error, :invalid_move}
  end
```

### Implementation
We will again put all the pawn-specific logic in it's own module.
```elixir
defmodule ExChess.Piece.Pawn do
  alias ExChess.{Board, Square, Piece}

  @spec legal_moves_basic(Board.t(), Square.t(), Piece.color()) :: [
          {non_neg_integer(), non_neg_integer()},
        ]
  def legal_moves_basic(
        _board = %{},
        _from_square = %Square{file: file, rank: rank},
        color
      ) do
    direction = direction(color)

    [{file, rank + direction}]
  end

  defp direction(:white), do: 1
  defp direction(:black), do: -1
end
```

I will let you handle enhancing the `LegalMoves.get_all/3` function. You need to make sure it handles pawns too.
As usual, you can also see the full code changes in [the github PR](https://github.com/SamiSuhail/ex_chess/pull/2).

## 3.2 - Two square advance on first move
Pretty self-explanatory. The first time a pawn is being moved, it is also able to advance two ranks in a single move.

### Tests
```elixir
  test "pawns can advance two squares on first move" do
    Arrange.new_game()
    |> Arrange.game_move("a2a4")
    |> Arrange.game_move("a7a5")
    |> Arrange.game_move("h2h4")
    |> Arrange.game_move("h7h5")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |rnbqkbnr| 8
    7 | pppppp | 7
    6 |        | 6
    5 |p      p| 5
    4 |P      P| 4
    3 |        | 3
    2 | PPPPPP | 2
    1 |RNBQKBNR| 1
      ----------
       abcdefgh
    """)
  end

  test "validation - pawns can't advance two squares on subsequent moves (white)" do
    result =
      Arrange.new_game()
      |> Arrange.game_move("a2a3")
      |> Arrange.game_move("b7b5")
      |> Arrange.game_move("a3a5")

    assert result == {:error, :invalid_move}
  end

  test "validation - pawns can't advance two squares on subsequent moves (black)" do
    result =
      Arrange.new_game()
      |> Arrange.game_move("a2a4")
      |> Arrange.game_move("b7b6")
      |> Arrange.game_move("a4a5")
      |> Arrange.game_move("b6b4")

    assert result == {:error, :invalid_move}
  end
```
### Implementation
We just need to add some extra conditional logic to `Pawn.legal_moves_basic/3`.
```diff
defmodule ExChess.Piece.Pawn do
  ...
  def legal_moves_basic(
        _board = %{},
        _from_square = %Square{file: file, rank: rank},
        color
      ) do
    direction = direction(color)

-   [{file, rank + direction}]
+   advance_once_move = {file, rank + direction}
+   advance_twice_move = {file, rank + direction * 2}
+   if rank == pawn_starting_rank(color),
+     do: [advance_once_move, advance_twice_move],
+     else: [advance_once_move]
  end

  defp direction(:white), do: 1
  defp direction(:black), do: -1
+ 
+ defp pawn_starting_rank(:white), do: 1
+ defp pawn_starting_rank(:black), do: 6
end
```

## 3.3 - Taking
Pawns in chess can not take opposing pieces while advancing, they can however take diagonally.
They can only move diagonally when taking a piece.

### Tests
I'm extending the `Arrange.new_game/0` function to now take an optional keyword list.

As test cases become increasingly complex, we will need an easier way of setting up the starting position without doing all moves one by one. This will come even more in handy once we start implementing path validation in the next step.
```elixir
  test "pawns can take diagonally" do
    Arrange.new_game(
      board: """
         abcdefgh
        ----------
      8 |rnbqkbnr| 8
      7 |p ppppp | 7
      6 |        | 6
      5 | p     p| 5
      4 |P     P | 4
      3 |        | 3
      2 | PPPPP P| 2
      1 |RNBQKBNR| 1
        ----------
         abcdefgh
      """
    )
    |> Arrange.game_move("a4b5")
    |> Arrange.game_move("h5g4")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |rnbqkbnr| 8
    7 |p ppppp | 7
    6 |        | 6
    5 | P      | 5
    4 |      p | 4
    3 |        | 3
    2 | PPPPP P| 2
    1 |RNBQKBNR| 1
      ----------
       abcdefgh
    """)
  end

  test "validation - pawns can't move diagonally when square is empty (white)" do
    result =
      Arrange.new_game()
      |> Arrange.game_move("a2b3")

    assert result == {:error, :invalid_move}
  end

  test "validation - pawns can't move diagonally when square is empty (black)" do
    result =
      Arrange.new_game()
      |> Arrange.game_move("a2a3")
      |> Arrange.game_move("a7b6")

    assert result == {:error, :invalid_move}
  end
```

### Implementation
All we need is a small addition to `Pawn.legal_moves_basic/3`.

It now checks the two squares diagonally in front of the pawn. If one of them has an opposing piece, it is considered a valid move and the pawn can take that piece.
```diff
  @spec legal_moves_basic(Board.t(), Square.t(), Piece.color()) :: [
          {non_neg_integer(), non_neg_integer()},
        ]
  def legal_moves_basic(
        board = %{},
        _from_square = %Square{file: file, rank: rank},
        color
      ) do
    direction = direction(color)

    advance_once_move = {file, rank + direction}
    advance_twice_move = {file, rank + direction * 2}

+   advance_moves =
      if rank == pawn_starting_rank(color),
        do: [advance_once_move, advance_twice_move],
        else: [advance_once_move]

+   take_moves =
+     [
+       {file + 1, rank + direction},
+       {file - 1, rank + direction},
+     ]
+     |> Enum.filter(fn {file, rank} ->
+       Square.valid?(file, rank) and
+         case Board.get(board, Square.new(file, rank)) do
+           %Piece{color: target_piece_color} -> target_piece_color != color
+           _ -> false
+         end
+     end)
+
+   Enum.concat(advance_moves, take_moves)
  end
```

The larger change for this step was the addition of optional parameters to `Arrange.new_game`. I won't be posting those in the blog post, but I recommend you implement that yourself.
As usual, you can also see the full code changes in [the github PR](https://github.com/SamiSuhail/ex_chess/pull/2).

## 3.4 - Validation - Cannot advance when path is not clear
The advance moves rely on the pawn's path being clear. This includes both the square the pawn is advancing to, and in case of a two-square advance, the square that's directly in front of the pawn must also be clear.
### Tests
I am making use of the new options that `Arrange.new_game/1` takes in extensively. I've also added a new `Arrange.color_at_play/2` function to make the setup more declarative than making dummy moves.

I am going through 3 different scenarios, and for each of them I assert both sides function identically.
```elixir
  test "validation - pawns cannot advance when the target square is occupied" do
    game =
      Arrange.new_game(
        board: """
           abcdefgh
          ----------
        8 |rnbqkbnr| 8
        7 |p pppppp| 7
        6 |P       | 6
        5 |        | 5
        4 |        | 4
        3 | p      | 3
        2 | PPPPPPP| 2
        1 |RNBQKBNR| 1
          ----------
           abcdefgh
        """
      )

    assert game
           |> Arrange.game_move("b2b3") ==
             {:error, :invalid_move}

    assert game
           |> Arrange.color_at_play(:black)
           |> Arrange.game_move("a7a6") ==
             {:error, :invalid_move}
  end

  test "validation - pawns cannot advance two squares when the target square is occupied" do
    game =
      Arrange.new_game(
        board: """
           abcdefgh
          ----------
        8 |rnbqkbnr| 8
        7 |p pppppp| 7
        6 |        | 6
        5 |P       | 5
        4 | p      | 4
        3 |        | 3
        2 | PPPPPPP| 2
        1 |RNBQKBNR| 1
          ----------
           abcdefgh
        """
      )

    assert game
           |> Arrange.game_move("b2b4") ==
             {:error, :invalid_move}

    assert game
           |> Arrange.color_at_play(:black)
           |> Arrange.game_move("a7a5") ==
             {:error, :invalid_move}
  end

  test "validation - pawns cannot advance two squares when the square directly in front is occupied" do
    game =
      Arrange.new_game(
        board: """
           abcdefgh
          ----------
        8 |rnbqkbnr| 8
        7 |p pppppp| 7
        6 |P       | 6
        5 |        | 5
        4 |        | 4
        3 | p      | 3
        2 | PPPPPPP| 2
        1 |RNBQKBNR| 1
          ----------
           abcdefgh
        """
      )

    assert game
           |> Arrange.game_move("b2b4") ==
             {:error, :invalid_move}

    assert game
           |> Arrange.color_at_play(:black)
           |> Arrange.game_move("a7a5") ==
             {:error, :invalid_move}
  end
```

### Implementation
We need to update `Pawn.legal_moves_basic/3` to ensure the advance moves are illegal when the square is occupied.
```diff
    advance_moves =
-     if rank == pawn_starting_rank(color),
-       do: [advance_once_move, advance_twice_move],
-       else: [advance_once_move]
+     cond do
+       Board.square_occupied?(board, Square.new(file, rank + direction)) ->
+         []
+       rank != pawn_starting_rank(color) or
+           Board.square_occupied?(board, Square.new(file, rank + direction * 2)) ->
+         [advance_once_move]
+       true ->
+         [advance_once_move, advance_twice_move]
+     end
```

I've also added a new `Board.square_occupied?/2` method. I didn't use `Map.has_key?/2` because I also want to return false when the key exists but the value is nil.
```elixir
defmodule ExChess.Board do
  ...
  @spec square_occupied?(t(), Square.t()) :: boolean()
  def square_occupied?(board = %{}, square = %Square{}),
    do: not is_nil(get(board, square))
end
```

## Conclusion
We might not yet have all the special moves, but we do now have functioning pawns.

They need functioning allies though.

### Up next
In part 4, all of the pieces on our board will be able to move.

Implementing the queen, bishop, and rook together makes sense, since their moves are all linear. The king is also linear, but he's limited to a single square.

The king, of course, has a special role on the board. We won't be looking at that just yet.

Stay tuned.