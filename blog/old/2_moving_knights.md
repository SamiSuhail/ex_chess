# 2 - Moving knights

This blog post is part of a series that will be walking you through the process of building a production-ready chess application using Elixir.

Each blog post is a separate PR in [the github repository](https://github.com/SamiSuhail/ex_chess), and each section of the blog post with the relevant code is a commit in that PR.

To look at the code, check out [this PR](https://github.com/SamiSuhail/ex_chess/pull/1).

### Agenda
- 2.1 - Piece movement
- 2.2 - Validation - No piece found
- 2.3 - Validation - Cannot move outside board bounds
- 2.4 - Validation - Cannot target own piece
- 2.5 - Validation - Must wait for your turn
- 2.6 - Validation - Must be legal move (knight)

## 2.1 - Piece movement

For the first stage, we will just add the ability to move pieces on the board. There will be absolutely zero validation.

### 2.1.1 - Tests
As you may have noticed, today is all about the knights.
For our first test, we're going to make sure that both the white and the black knights can move.

I will be adding a method on the `Arrange` module in order to keep the tests implementation-agnostic.

As usual, make the tests pass yourself first, and only then look into my own implementation.

There's a lot of room for choice here. Where do you put the code? What parameter(s) do you take in?

```elixir
  test "knights can move" do
    Arrange.new_game()
    |> Arrange.game_move("b1c3")
    |> Arrange.game_move("b8c6")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |r bqkbnr| 8
    7 |pppppppp| 7
    6 |  n     | 6
    5 |        | 5
    4 |        | 4
    3 |  N     | 3
    2 |PPPPPPPP| 2
    1 |R BQKBNR| 1
      ----------
       abcdefgh
    """)
  end
```

### 2.1.2 - Implementation

#### board.ex
First thing's first, we need a way to update the board state.
```elixir
defmodule ExChess.Board do
  ...
  @spec unset(t(), Square.t()) :: t()
  def unset(board = %{}, square = %Square{}),
    do: Map.delete(board, square)

  @spec set(t(), Square.t(), Piece.t()) :: t()
  def set(board = %{}, square = %Square{}, piece = %Piece{}),
    do: Map.put(board, square, piece)
end
```

#### game.ex
We need to add a method on the `Game` module. You need to pass in the square of the piece you want to move, and the square you want to place it on.
```elixir
defmodule ExChess.Game do
  ...
  @spec move(t(), Square.t(), Square.t()) :: t()
  def move(
        game = %__MODULE__{board: board},
        from_square = %Square{},
        to_square = %Square{}
      ) do
    piece = Board.get(board, from_square)

    updated_board =
      Board.unset(board, from_square)
      |> Board.set(to_square, piece)

    %__MODULE__{game | board: updated_board}
  end
end
```

The code for the `Arrange` module's new `game_move/2` function can be found on the github repository, I won't be adding those to the blog posts. I suggest you just implement that yourself.

And with that, our test is now passing. Time to start adding some validation.

## 2.2 - Validation - No piece found

In case the square I am targeting when trying to move a piece is empty, a validation error occurs.

### 2.2.1 - Tests
Implement the code to make this test pass before you read on.
```elixir
  test "validation - no piece found" do
    result =
      Arrange.new_game()
      |> Arrange.game_move("a3a4")

    assert result == {:error, :invalid_move}
  end
```

### 2.2.2 - Implementation

```diff
  @spec move(t(), Square.t(), Square.t()) :: t()
  def move(
        game = %__MODULE__{board: board},
        from_square = %Square{},
        to_square = %Square{}
      ) do
-   piece = Board.get(board, from_square)
+   case Board.get(board, from_square) do
+     nil ->
+       {:error, :invalid_move}

+     piece ->
        updated_board =
          Board.unset(board, from_square)
          |> Board.set(to_square, piece)

        %__MODULE__{game | board: updated_board}
+   end
  end
```

## 2.3 - Validation - Cannot move outside board bounds

We're not adding any tests for this, just a guard on the Game module in order to sanitize inputs.

```diff
defmodule ExChess.Game do
  ...
  @spec move(t(), Square.t(), Square.t()) :: t()
  def move(
        game = %__MODULE__{board: board},
        from_square = %Square{},
        to_square = %Square{}
      )
+     when from_square.file in 0..7 and from_square.rank in 0..7 and to_square.file in 0..7 and
+            to_square.rank in 0..7 do
    ...
  end
end
```

## 2.4 - Validation - Cannot target own piece

### 2.4.1 - Tests
```elixir
  test "validation - cannot target own piece" do
    result =
      Arrange.new_game()
      |> Arrange.game_move("b1d2")

    assert result == {:error, :invalid_move}
  end
```

### 2.4.2 - Implementation
I basically rewrote the move method to use a with clause instead.
```elixir
defmodule ExChess.Game do
  ...
  @spec move(t(), Square.t(), Square.t()) :: t()
  def move(
        game = %__MODULE__{board: board},
        from_square = %Square{},
        to_square = %Square{}
      )
      when from_square.file in 0..7 and from_square.rank in 0..7 and to_square.file in 0..7 and
             to_square.rank in 0..7 do
    with piece = %Piece{} <- Board.get(board, from_square),
         target_piece = Board.get(board, to_square),
         true <- is_nil(target_piece) or target_piece.color != piece.color do
      updated_board =
        Board.unset(board, from_square)
        |> Board.set(to_square, piece)

      %__MODULE__{game | board: updated_board}
    else
      _ -> {:error, :invalid_move}
    end
  end
  ...
end
```

## 2.5 - Validation - Must wait for your turn
Okay so now we need to track some more state in the game struct.
We need some way of knowing which color is at play.

There are many ways to go about this, and odds are you will do something different than me, so do make sure to write the code yourself first as always.

### 2.5.1 - Tests

```elixir
  test "validation - must wait for your turn" do
    result =
      Arrange.new_game()
      |> Arrange.game_move("b1c3")
      |> Arrange.game_move("c3b1")

    assert result == {:error, :invalid_move}
  end
```

### 2.5.2 - Implementation

So there are multiple possible approaches here.
The simplest: add a new `color_at_play` property on the `Game` struct.

We could also just have a counter of the number of turns that have passed, and do a modulo 2.

Or if we want to really go big, we can keep track of the full history of moves, and check what color moved last.

By the end of this project, we will have implemented a history of the moves either way, but for now I am keeping it simple.

I've added the `color_at_play` property to the `Game` struct, and have updated the `move/3` function.

```diff
defmodule ExChess.Game do
  ...
  @spec move(t(), Square.t(), Square.t()) :: t()
  def move(
        game = %__MODULE__{board: board},
        from_square = %Square{},
        to_square = %Square{}
      )
      when from_square.file in 0..7 and from_square.rank in 0..7 and to_square.file in 0..7 and
             to_square.rank in 0..7 do
    with piece = %Piece{} <- Board.get(board, from_square),
+        true <- piece.color == game.color_at_play,
         target_piece = Board.get(board, to_square),
         true <- is_nil(target_piece) or target_piece.color != piece.color do
      updated_board =
        Board.unset(board, from_square)
        |> Board.set(to_square, piece)

      %__MODULE__{
        game
        | board: updated_board,
+         color_at_play: Piece.flip_color(game.color_at_play),
      }
    else
      _ -> {:error, :invalid_move}
    end
  end
end
```

I've also added a new `Piece.flip_color/1` function.
```elixir
defmodule ExChess.Piece do
  ...
  @spec flip_color(color()) :: color()
  def flip_color(:white), do: :black
  def flip_color(:black), do: :white
end
```

## 2.6 - Validation - Must be legal move (knight)

So now we start entering the fun territory. We start adding rules that are specific to a piece type. Each piece type has a different pattern of movement. Since we've started with nights, let's make sure they are only ever allowed to move in an L shape.

### 2.6.1 - Tests
```elixir
  test "validation - must be legal move (knight)" do
    result =
      Arrange.new_game()
      |> Arrange.game_move("b1b3")

    assert result == {:error, :invalid_move}
  end
```

### 2.6.2 - Implementation
Let's start by adding a `Square.valid?/2` function, as we will need that when evaluating which moves are legal.
```elixir
defmodule ExChess.Square do
  ...
  @spec valid?(non_neg_integer(), non_neg_integer()) :: boolean()
  def valid?(file, rank) when file in @valid_files and rank in @valid_ranks, do: true
  def valid?(_, _), do: false
end
```

Next let's add a new module `LegalMoves` and a function `get_all/3`. You'll notice one of the arguments `board` is not even used in the implementation. That is unique to knights, all other pieces will need that contextual information when determining the legal moves.

```elixir
defmodule ExChess.LegalMoves do
  alias ExChess.{Board, Square, Piece}

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

  @spec get_all(Board.t(), Square.t(), Piece.t()) :: [Square.t()]
  def get_all(
        _board = %{},
        from_square = %Square{},
        _piece = %Piece{type: :n}
      ) do
    @patterns_knight
    |> Enum.map(fn {file_shift, rank_shift} ->
      {
        from_square.file + file_shift,
        from_square.rank + rank_shift
      }
    end)
    |> Enum.filter(fn {file, rank} -> Square.valid?(file, rank) end)
    |> Enum.map(fn {file, rank} -> Square.new(file, rank) end)
  end
end
```

Now let's make sure the `Game.move/3` function validates the `to_square` is a legal move for the piece.
```diff
    with piece = %Piece{} <- Board.get(board, from_square),
         true <- piece.color == game.color_at_play,
         target_piece = Board.get(board, to_square),
         true <- is_nil(target_piece) or target_piece.color != piece.color,
+        legal_moves = LegalMoves.get_all(board, from_square, piece),
+        true <- to_square in legal_moves do
      updated_board =
```

And just like that, our test is now passing, and our knights' movements are fully validated.

## Conclusion

We used to have just a static board with a bunch of pieces on it that we could only look at and not really do anything with.

Why the heck you starting a game that you can't even play a move in???

Today, our game came to life. The horses started jumping around. But it is still rather dull when their friends can't join them.

### Up next
In part 3, we will begin activating our pawns.
The pawns are actually some of the most difficult pieces to implement, interestingly. They are rather... unique.

We won't even add any en passant or pawn promotion logic yet. That'll come much later.