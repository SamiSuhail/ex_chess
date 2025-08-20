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
- 1.2 - `Game.move(game, from_square, to_square)`
- 1.3 - Validation - movement patterns (knight, king)
- 1.4 - `Game.list_legal_moves(game, from_square)`
- 1.5 - Validation - square cannot be empty
- 1.6 - Validation - movement patterns (pawn)
- 1.7 - Validation - movement patterns (bishop, rook, queen)

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

## Conclusion

### Up next

