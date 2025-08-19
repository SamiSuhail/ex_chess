# 1 - Pieces and a board
This is the first of a series of blog posts that will be walking you through the process of building a production-ready chess application using Elixir.

Check out the [introductory post](https://dev.to/samisuhail/why-your-first-elixir-project-should-be-a-multiplayer-chess-game).

_Soooo... The chess game. Version 0.
A board and some pieces. Nothing else.
Pieces can't move yet.
Simple, right?_
As promised.

## 1.1 - The test

As promised, you'll be doing a bunch of writing and refactoring too, it won't be just me.

I'm only going to give you the code for the test, and it's your job to make it pass. This will be a recurring theme throughout this project.

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

Do not proceed before you've made this test pass. 
`Arrange` and `Assert` are helper modules used only for the tests.
They will provide us with an implementation-agnostic interface for our tests, while also keeping things more visual for clarity's sake.


## 1.2 - Board representation

I went through [chessprogramming.org](https://www.chessprogramming.org/Board_Representation) and looked at other implementations on the BEAM (like erlang's [Binbo](https://github.com/DOBRO/binbo)). Bitboards look like the most optimal solution.

We're not going to do bitboards though, not for the first version anyways. The board module will be quite self-contained, so we should be able to update our representation pretty easily at a later stage.

For clarity's sake, we're starting with a simple map. The key is the board's square, and the value is the piece occupying said square.

Ah, yes, type masturbation. Lovely.

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

I could have gone for tuples instead of structs for the piece and the square. I don't really have a strong opinion on which is better.

```elixir
# 
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

## 1.3 - Start a new game
Okay, so the types are done, now we need to arrange all the pieces on the board.

I was in two minds on where I want this code to live.
On one hand, it seems like it's very local to the `Board` module.

On the other hand, a simpler, slimmer `Board` abstraction sounds more fitting.
That way it could be reused for another gamemode with a different sized board, or a different starting position.

Ah, yes, predicting the future. Always a good idea. I'll stop doing that and just add it to the `Board`.

I tried a couple of different implementations. I ended up chosing the simplest one - just hard-code it. It's quite... vertical? - which is aesthetically unpleasant, but it still has the lowest maintenance overhead.

So here's where we're at.
```elixir
defmodule ExChess.Piece do
  ...
  @valid_types [:p, :r, :n, :b, :q, :k]
  @valid_colors [:white, :black]

  def new(type, color) when type in @valid_types and color in @valid_colors,
    do: %__MODULE__{type: type, color: color}
end

defmodule ExChess.Square do
  ...
  @valid_files 0..7
  @valid_ranks 0..7

  def new(file, rank) when file in @valid_files and rank in @valid_ranks,
    do: %__MODULE__{file: file, rank: rank}
end

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
                       {0, 7, :r, :black},
                       {1, 7, :n, :black},
                       {2, 7, :b, :black},
                       {3, 7, :q, :black},
                       {4, 7, :k, :black},
                       {5, 7, :b, :black},
                       {6, 7, :n, :black},
                       {7, 7, :r, :black},
                       {0, 6, :p, :black},
                       {1, 6, :p, :black},
                       {2, 6, :p, :black},
                       {3, 6, :p, :black},
                       {4, 6, :p, :black},
                       {5, 6, :p, :black},
                       {6, 6, :p, :black},
                       {7, 6, :p, :black},
                     ]
                     |> Map.new(fn {file, rank, piece_type, piece_color} ->
                       {Square.new(file, rank), Piece.new(piece_type, piece_color)}
                     end)

  def new(), do: @starting_position
end

defmodule ExChess.Game do
  ...
  def new(), do: %__MODULE__{board: Board.new()}
end
```

And with that, you have a new game. We're all done with the actual code. Let's try it out in iex.
```elixir
iex(1)> ExChess.Game.new()
%Game{
  board: %{
    %Square{file: 0, rank: 0} => %Piece{type: :r, color: :white},
    %Square{file: 0, rank: 1} => %Piece{type: :p, color: :white},
    %Square{file: 0, rank: 6} => %Piece{type: :p, color: :black},
    %Square{file: 0, rank: 7} => %Piece{type: :r, color: :black},
    %Square{file: 1, rank: 0} => %Piece{type: :n, color: :white},
    %Square{file: 1, rank: 1} => %Piece{type: :p, color: :white},
    %Square{file: 1, rank: 6} => %Piece{type: :p, color: :black},
    %Square{file: 1, rank: 7} => %Piece{type: :n, color: :black},
    %Square{file: 2, rank: 0} => %Piece{type: :b, color: :white},
    %Square{file: 2, rank: 1} => %Piece{type: :p, color: :white},
    %Square{file: 2, rank: 6} => %Piece{type: :p, color: :black},
    %Square{file: 2, rank: 7} => %Piece{type: :b, color: :black},
    %Square{file: 3, rank: 0} => %Piece{type: :q, color: :white},
    %Square{file: 3, rank: 1} => %Piece{type: :p, color: :white},
    %Square{file: 3, rank: 6} => %Piece{type: :p, color: :black},
    %Square{file: 3, rank: 7} => %Piece{type: :q, color: :black},
    %Square{file: 4, rank: 0} => %Piece{type: :k, color: :white},
    %Square{file: 4, rank: 1} => %Piece{type: :p, color: :white},
    %Square{file: 4, rank: 6} => %Piece{type: :p, color: :black},
    %Square{file: 4, rank: 7} => %Piece{type: :k, color: :black},
    %Square{file: 5, rank: 0} => %Piece{type: :b, color: :white},
    %Square{file: 5, rank: 1} => %Piece{type: :p, color: :white},
    %Square{file: 5, rank: 6} => %Piece{type: :p, color: :black},
    %Square{file: 5, rank: 7} => %Piece{type: :b, color: :black},
    %Square{file: 6, rank: 0} => %Piece{type: :n, color: :white},
    %Square{file: 6, rank: 1} => %Piece{type: :p, color: :white},
    %Square{file: 6, rank: 6} => %Piece{type: :p, color: :black},
    %Square{file: 6, rank: 7} => %Piece{type: :n, color: :black},
    %Square{file: 7, rank: 0} => %Piece{type: :r, color: :white},
    %Square{file: 7, rank: 1} => %Piece{type: :p, color: :white},
    %Square{file: 7, rank: 6} => %Piece{type: :p, color: :black},
    %Square{file: 7, rank: 7} => %Piece{type: :r, color: :black}
  }
}
```

## 1.4 - The test helpers

With the above we're still not completely ready to run our tests. We need to implement the `Arrange` and `Assert` helper modules.
I won't paste the code in here, but you can find it on [the github repo](https://github.com/SamiSuhail/ex_chess). If you check this blog post's file and list the history, you will find all the code commits that go with it.

I encourage you to instead implement it yourself, but here's a quick description of my code:
`Arrange` is litterally just a wrapper around `Game.new/0`
`Assert` gets the game and the expected board as parameters, parses the board to a similar string representation, and asserts the two strings are equal. You could also instead map the expected string to a board and compare the boards, but I thought that would make it less readable when you see a test failure.

I also needed to add a method on the board that allows me to get the piece on a particular square. This could have been avoided by enumerating the board instead, but we're going to need it later anyways, so might as well.
```elixir
defmodule ExChess.Board do
  ...
  @spec get(t(), Square.t()) :: Piece.t() | nil
  def get(board = %{}, square = %Square{}), do: Map.get(board, square)

  @spec get(t(), non_neg_integer(), non_neg_integer()) :: Piece.t() | nil
  def get(board = %{}, file, rank), do: get(board, Square.new(file, rank))
end
```

And just like that, our test is now passing.

## Conclusion

With that, we have the foundations of our chess game. Pieces and a board.

### Up next

In part 2, we will be implementing the moving of pieces. We'll start with knights, as they are the easiest to implement.
