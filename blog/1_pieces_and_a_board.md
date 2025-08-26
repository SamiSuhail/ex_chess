# 1 - Pieces and a board
This blog post is part of a series that will be walking you through the process of building a production-ready chess application using Elixir.

Each blog post is a separate PR in [the github repository](https://github.com/SamiSuhail/ex_chess), and each section of the blog post with the relevant code is a commit in that PR.

To look at the code, check out [this PR](https://github.com/SamiSuhail/ex_chess/pull/1).

Check out the [introductory post](TODO).

#### IMPORTANT
This series is a practical one. For each step, I will start by giving you the tests. Always start by making the tests pass on your own. After making them pass, check if there is anything you want to refactor. Only once you're done with that should you look at my implementations. Otherwise the posts will be of limited value to you.

## Agenda
So, as promised - we're going to have a board. That board is going to have all of the chess pieces. There will be a way to check the valid moves for a piece, and the pieces will all be able to move as per the patterns described in the chess rules.

We'll be going through:
- 1.0 - Board representation
- 1.1 - `Game.new()`
- 1.2 - `Game.move(game, move)`
- 1.3 - Validation - movement patterns (knight, king)
- 1.4 - Validation - cannot take own piece
- 1.5 - `Game.list_legal_moves(game, from_square)`
- 1.6 - Validation - square cannot be empty
- 1.7 - Validation - movement patterns (pawn)
- 1.8 - Validation - movement patterns (bishop, rook, queen)

## 1.0 - Board representation

I went through [chessprogramming.org](https://www.chessprogramming.org/Board_Representation) and looked at other implementations on the BEAM (like erlang's [Binbo](https://github.com/DOBRO/binbo)). Bitboards look like the most optimal solution.

We're not going to do bitboards though, not for the first version anyways. The board module will be quite self-contained, so we should be able to update our representation pretty easily at a later stage.

For clarity's sake, we're starting with a simple map for the board. The key is the board's square, and the value is the piece occupying said square.

TL;DR:
```elixir
%Game{
    board: map(
        %Square{file: non_neg_integer(), rank: non_neg_integer()},
        %Piece{
            type: :p | :r | :n | :b | :q | :k, 
            color: :white | :black
        }
    )
}
```

I could have gone for tuples instead of structs for the piece and the square. I usually like structs better for the flexibility in the pattern matching.

The full type definitions below.
```elixir
defmodule ExChess.Square do
  @type t() :: %__MODULE__{
          file: non_neg_integer(),
          rank: non_neg_integer(),
        }
  @enforce_keys [:file, :rank]
  defstruct [:file, :rank]
end

defmodule ExChess.Piece do
  @type type() :: :p | :r | :n | :b | :q | :k
  @type color() :: :white | :black
  @type t() :: %__MODULE__{
          type: type(),
          color: color(),
        }
  @enforce_keys [:type, :color]
  defstruct [:type, :color]
end

defmodule ExChess.Board do
  alias ExChess.{Square, Piece}
  @type t() :: %{Square.t() => Piece.t()}
end

defmodule ExChess.Game do
  alias ExChess.Board

  @type t() :: %__MODULE__{
          board: Board.t(),
        }
  @enforce_keys [:board]
  defstruct [:board]
end
```

## 1.1 - `Game.new()`
In this section we're going to make sure we can start a new game and the board contains all the pieces.

### Test
You're going to notice a pattern in this guide. The testing is always a foundational part of the process. The first thing we're going to do is write a test. It won't compile, and it most definitely won't pass, but still we are starting with the test.

I think a chess app is an ideal candidate for TDD, since the requirements are very clear. But still, the TDD must be done correctly. You should only ever test implementation behavior very selectively, that is bound to make your refactors more difficult instead of easier. That is sometimes a desired property, but often people just default to testing every module and "public" function.

With that in mind, here's our very first test.
```elixir
  test "new game" do
    Arrange.new_game()
    |> Assert.game_board("""
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
  end
```

There are a few things to notice here.
`Arrange` - will be used to ease the test setup. An abstraction over the actual game API.
`Assert` - similarly, will help with asserting the outcome of our tests. 
Both of the above are used to help with one main objective. Make refactors easy.

The main aim with production software, which this will be one day, is to make sure your design today does not impede your design tomorrow. You and your software need to remain versatile. What you definitely don't want, is your tests stopping you from refactoring.

That is why the assertion does not work directly with the types we defined earlier, instead it uses a visual string representation of the board.

#### Your turn
Now is the right time to stop reading my endless rants, and write some code instead. Make the test pass, write the helper modules yourself, write the actual code that creates a new board and places all the pieces on it. Do your part.

### Implementation
First, let's expose functions for creating new pieces and squares.
```elixir
defmodule ExChess.Piece do
  ...
  @spec new(type(), color()) :: ExChess.Piece.t()
  def new(type, color), do: %__MODULE__{type: type, color: color}
end

defmodule ExChess.Square do
  ...
  @spec new(non_neg_integer(), non_neg_integer()) :: t()
  def new(file, rank), do: %__MODULE__{file: file, rank: rank}
end
```

Next step is to add a function on the board module that returns the starting position with all the pieces. I tried a couple of different approaches, and decided that hard-coding them into an attribute is the one I liked the most.
```elixir
defmodule ExChess.Board do
  ...
  @starting_position [
                       {0, 0, :r, :white},
                       {1, 0, :n, :white},
                       {2, 0, :b, :white},
                       {3, 0, :q, :white},
                       {4, 0, :k, :white},
                       {5, 0, :b, :white},
                       {6, 0, :n, :white},
                       {7, 0, :r, :white},
                       {0, 1, :p, :white},
                       {1, 1, :p, :white},
                       {2, 1, :p, :white},
                       {3, 1, :p, :white},
                       {4, 1, :p, :white},
                       {5, 1, :p, :white},
                       {6, 1, :p, :white},
                       {7, 1, :p, :white},
                       {0, 6, :p, :black},
                       {1, 6, :p, :black},
                       {2, 6, :p, :black},
                       {3, 6, :p, :black},
                       {4, 6, :p, :black},
                       {5, 6, :p, :black},
                       {6, 6, :p, :black},
                       {7, 6, :p, :black},
                       {0, 7, :r, :black},
                       {1, 7, :n, :black},
                       {2, 7, :b, :black},
                       {3, 7, :q, :black},
                       {4, 7, :k, :black},
                       {5, 7, :b, :black},
                       {6, 7, :n, :black},
                       {7, 7, :r, :black},
                     ]
                     |> Map.new(fn {file, rank, piece_type, piece_color} ->
                       {Square.new(file, rank), Piece.new(piece_type, piece_color)}
                     end)

  @spec new() :: t()
  def new(), do: @starting_position
end
```

And of course, our entry point, the `Game` module.
```elixir
defmodule ExChess.Game do
  ...
  @spec new() :: t()
  def new(),
    do: %__MODULE__{
      board: Board.new(),
    }
end
```

### Testing helpers
`Arrange` is extremely minimalistic, but `Assert` has quite a bit of code to parse the board to a string.
```elixir
defmodule ExChessTest.Arrange do
  alias ExChess.Game

  def new_game(), do: Game.new()
end

defmodule ExChessTest.Assert do
  import ExUnit.Assertions
  alias ExChess.{Game, Board, Square, Piece}

  @rank_joiner "\n"
  @file_joiner ""
  def game_board(_game = %Game{board: board}, expected_board_string) do
    ranks_text =
      7..0//-1
      |> Enum.map(fn rank -> game_board_rank(rank, board) end)
      |> Enum.join(@rank_joiner)

    assert """
              abcdefgh
             ----------
           #{ranks_text}
             ----------
              abcdefgh
           """ == expected_board_string
  end

  defp game_board_rank(rank, board = %{}) do
    rank_label = (rank + 1) |> to_string()

    pieces_text =
      0..7
      |> Enum.map(fn file -> Board.get(board, Square.new(file, rank)) |> piece_label() end)
      |> Enum.join(@file_joiner)

    "#{rank_label} |#{pieces_text}| #{rank_label}"
  end

  defp piece_label(nil), do: " "

  defp piece_label(%Piece{type: :p, color: :white}), do: "P"
  defp piece_label(%Piece{type: :p, color: :black}), do: "p"
  defp piece_label(%Piece{type: :r, color: :white}), do: "R"
  defp piece_label(%Piece{type: :r, color: :black}), do: "r"
  defp piece_label(%Piece{type: :n, color: :white}), do: "N"
  defp piece_label(%Piece{type: :n, color: :black}), do: "n"
  defp piece_label(%Piece{type: :b, color: :white}), do: "B"
  defp piece_label(%Piece{type: :b, color: :black}), do: "b"
  defp piece_label(%Piece{type: :q, color: :white}), do: "Q"
  defp piece_label(%Piece{type: :q, color: :black}), do: "q"
  defp piece_label(%Piece{type: :k, color: :white}), do: "K"
  defp piece_label(%Piece{type: :k, color: :black}), do: "k"
end
```
You'll notice that I've added a new `Board.get/2` function for the arrange module. This will later be used in the application code as well. It's a very simple wrapper of `Map.get`.
```elixir
defmodule ExChess.Board do
  ...
  @spec get(t(), Square.t()) :: Piece.t() | nil
  def get(board = %{}, square = %Square{}), do: Map.get(board, square)
end
```

And with that, the test is green.

## 1.2 - `Game.move(game, move)`
Okay at this stage we do not care one bit whether ot not the move is valid, we just want to be able to move the pieces on the board.

### Test
A simple, single move. The white knight should be able to move to `c3` after starting a new game.

```elixir
  test "move" do
    Arrange.new_game()
    |> Arrange.game_move("b1c3")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |rnbqkbnr| 8
    7 |pppppppp| 7
    6 |        | 6
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

You'll notice there's a new `Arrange.game_move/2` function. Thanks to that abstraction, our tests can ran independent of the `Game`'s api. If tomorrow I decide to change the way I represent a move, I only need to make changes to my `Arrange` module, and all of the tests can still run.

#### Your turn
Make the test pass.

### Implementation
First, we're going to need some way of updating the board's state and a way to represent the moves.
```elixir
defmodule ExChess.Board do
  ...
  @spec set(t(), Square.t(), Piece.t()) :: t()
  def set(
        board = %{},
        square = %Square{},
        piece = %Piece{}
      ) do
    board |> Map.put(square, piece)
  end

  @spec unset(t(), Square.t()) :: t()
  def unset(
        board = %{},
        square = %Square{}
      ) do
    board |> Map.delete(square)
  end
end

defmodule ExChess.Move do
  alias ExChess.Square

  @type t() :: %__MODULE__{
          from: Square.t(),
          to: Square.t(),
        }
  @enforce_keys [:from, :to]
  defstruct [:from, :to]

  @spec new(Square.t(), Square.t()) :: t()
  def new(from, to), do: %__MODULE__{from: from, to: to}
end
```

Now we have everything we need to implement `Game.move`.
```elixir
defmodule ExChess.Game do
  ...
  @spec move(t(), Move.t()) :: t()
  def move(
        game = %__MODULE__{board: board},
        _move = %Move{from: from, to: to}
      ) do
    piece = Board.get(board, from)

    updated_board =
      board
      |> Board.set(to, piece)
      |> Board.unset(from)

    %__MODULE__{game | board: updated_board}
  end
end
```

As simple as that. Get the piece from the board, set it on `to`, and unset it from the it's previous square.

### Testing helpers
`Arrange.game_move` does some very basic parsing.

```elixir
defmodule ExChessTest.Arrange do
  ...
  def game_move(game, move_text) do
    move = parse_move(move_text)
    Game.move(game, move)
  end

  defp parse_move(<<
         from_file::binary-size(1),
         from_rank::binary-size(1),
         to_file::binary-size(1),
         to_rank::binary-size(1)
       >>) do
    from_square = text_to_square(from_file, from_rank)
    to_square = text_to_square(to_file, to_rank)

    Move.new(from_square, to_square)
  end

  defp text_to_square(file, rank),
    do: Square.new(file_to_index(file), rank_to_index(rank))

  defp file_to_index("a"), do: 0
  defp file_to_index("b"), do: 1
  defp file_to_index("c"), do: 2
  defp file_to_index("d"), do: 3
  defp file_to_index("e"), do: 4
  defp file_to_index("f"), do: 5
  defp file_to_index("g"), do: 6
  defp file_to_index("h"), do: 7

  defp rank_to_index("1"), do: 0
  defp rank_to_index("2"), do: 1
  defp rank_to_index("3"), do: 2
  defp rank_to_index("4"), do: 3
  defp rank_to_index("5"), do: 4
  defp rank_to_index("6"), do: 5
  defp rank_to_index("7"), do: 6
  defp rank_to_index("8"), do: 7
end
```
I made use of pattern matching to map the files and ranks to their index. I just really like it. Feel free to replace it with a map if you prefer that.

## 1.3 - Validation - movement patterns (knight, king)
This is the first bit of validation we're adding - we don't want our pieces teleporting left and right on the board.

We're starting with the two easiest ones to implement. The knight and the king.

### Test
Okay so we already have a scenario checking whether the knight can move a certain way. Now let's add a test that there are ways in which it cannot move.

```elixir
  test "invalid move - movement pattern" do
    Arrange.new_game()
    |> Arrange.game_move("b1b3")
    |> Assert.invalid_move()
  end
```

### Implementation
I've actally gone through this code multiple times, and the initial implementation will be a quick and dirty one that we will refactor in a later step. If I were to structure the code in a certain way before you had the context for it that would not feel natural.

For the movements that are allowed to a certain piece, I've decided to represent them as a tuple with 2 integers representing the shift on the file and rank respectively.

So all I am doing now is ensuring that the input move matches one of the movement patterns for that piece.
```elixir
defmodule ExChess.Game do
  ...
  @spec move(t(), Move.t()) :: t() | error()
  def move(
        game = %__MODULE__{board: board},
        move = %Move{from: from, to: to}
      ) do
    piece = Board.get(board, from)

    if valid_move?(piece, move) do
      # update board
    else
      {:error, :invalid_move}
    end
  end

  defp valid_move?(%Piece{type: piece_type}, move = %Move{}) do
    patterns(piece_type)
    |> valid_move_pattern?(move)
  end

  @king_patterns [
    {-1, -1},
    {-1, 0},
    {-1, 1},
    {0, -1},
    {0, 1},
    {1, -1},
    {1, 0},
    {1, 1},
  ]

  @knight_patterns [
    {-2, -1},
    {-2, 1},
    {-1, -2},
    {-1, 2},
    {1, -2},
    {1, 2},
    {2, -1},
    {2, 1},
  ]

  defp patterns(:k), do: @king_patterns
  defp patterns(:n), do: @knight_patterns

  defp valid_move_pattern?(patterns, %Move{from: from, to: to}) do
    patterns
    |> Enum.any?(fn {file_shift, rank_shift} ->
      from.file + file_shift == to.file and
        from.rank + rank_shift == to.rank
    end)
  end
end
```

And of course, a minor addition to the `Assert` module.
```elixir
defmodule ExChessTest.Assert do
  ...
  def invalid_move(error), do: assert(error == {:error, :invalid_move})
end
```

## 1.4 - Validation - cannot take own piece
This one is simple. A move is only valid if we're not trying to take our own piece.

### Test
```elixir
  test "invalid move - cannot take own piece" do
    Arrange.new_game()
    |> Arrange.game_move("b1d2")
    |> Assert.invalid_move()
  end
```

### Implementation
We're just adding an additional condition to `valid_move?`. We want to check what piece is on the target square, and if it is the same color as the piece we're moving, that move will be considered invalid. If the target square is empty, the move is valid.

To do that, we'll need to add an additional parameter - the board. We will be using that to check the contents of the target square.

```elixir
defmodule ExChess.Piece do
  ...
  @spec same_color?(t() | nil, t() | nil) :: boolean()
  def same_color?(%__MODULE__{color: color}, %__MODULE__{color: color}), do: true
  def same_color?(_, _), do: false
end

defmodule ExChess.Game do
  ...
  defp valid_move?(board = %{}, piece = %Piece{}, move = %Move{}) do
    target_piece = Board.get(board, move.to)

    not Piece.same_color?(piece, target_piece) and
      patterns(piece.type)
      |> valid_move_pattern?(move)
  end
end
```

## Conclusion

### Up next

