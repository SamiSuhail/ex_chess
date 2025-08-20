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
- 1.1 - Adding the pieces to the board
  - 1.1.1 - Testing
  - 1.1.2 - Starting a new game
- 1.2 - The pieces can move
- 1.3 - Validation - movement patterns (knight, king)
- 1.4 - Where can I move?
  - 1.4.1 - Testing
  - 1.4.2 - List moves for piece
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

## Conclusion

### Up next

