# 4 - Pawns are special

This blog post is part of a series that will be walking you through the process of building a production-ready chess application using Elixir.

Each blog post is a separate PR in [the github repository](https://github.com/SamiSuhail/ex_chess), and each section of the blog post with the relevant code is a commit in that PR.

To look at the code, check out [this PR](https://github.com/SamiSuhail/ex_chess/pull/4).

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
- 3 - [Lines of chess](TODO)
  - 3.1 - Rooks
  - 3.2 - Bishops
  - 3.3 - Queens
  - 3.4 - Validation - cannot move when path is blocked

## Agenda
We've implemented the basic set of moves for all of our pieces. Today is all about the special moves. Those will represent a bit of a new challenge for us - not only do we need to add more validation rules, but those new moves are also going to affect how we update the board state.

- 4.1 - En passant
- 4.2 - Promotion
- 4.3 - Validation - pawn cannot promote to king or pawn
- 4.4 - Validation - pawn cannot promote if not on final square
- 4.5 - Validation - pawn cannot advance to final rank without promoting

## 4.1 - En passant
In case you haven't heard of [en passant](https://en.wikipedia.org/wiki/En_passant) - it's a special rule in chess that allows you to capture an opponents pawn with your own pawn even if it is not diagonally in front, under some conditions of course. I won't go into detail on what the conditions are but I absolutely recommend you look into it if it's not something you already know.

### Test
The tests are by no means comprehensive, there are so many edge cases that we might want to validate. I stopped myself to the happy path plus three validation error assertions.

```elixir
  test "en passant" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |   k    | 8
      7 |   p    | 7
      6 |        | 6
      5 |  P     | 5
      4 |    p   | 4
      3 |        | 3
      2 |   P    | 2
      1 |   K    | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("d7d5")
    |> Arrange.game_move("c5d6")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |   k    | 8
    7 |        | 7
    6 |   P    | 6
    5 |        | 5
    4 |    p   | 4
    3 |        | 3
    2 |   P    | 2
    1 |   K    | 1
      ----------
       abcdefgh
    """)

    # black
    Arrange.game_move(game, "d2d4")
    |> Arrange.game_move("e4d3")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |   k    | 8
    7 |   p    | 7
    6 |        | 6
    5 |  P     | 5
    4 |        | 4
    3 |   p    | 3
    2 |        | 2
    1 |   K    | 1
      ----------
       abcdefgh
    """)
  end

  test "validation - cannot en passant if last move was not two square advance" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |   k    | 8
      7 |   p    | 7
      6 |        | 6
      5 |  P     | 5
      4 |    p   | 4
      3 |        | 3
      2 |   P    | 2
      1 |   K    | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("d7d6")
    |> Arrange.game_turn(:black)
    |> Arrange.game_move("d6d5")
    |> Arrange.game_move("c5d6")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(game, "d2d3")
    |> Arrange.game_turn(:white)
    |> Arrange.game_move("d3d4")
    |> Arrange.game_move("e4d3")
    |> Assert.invalid_move()
  end

  test "validation - cannot en passant if two square advance was two moves ago" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |   k    | 8
      7 |   p    | 7
      6 |        | 6
      5 |  P     | 5
      4 |    p   | 4
      3 |        | 3
      2 |   P    | 2
      1 |   K    | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("d7d5")
    |> Arrange.game_turn(:black)
    |> Arrange.game_move("d8c8")
    |> Arrange.game_move("c5d6")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(game, "d2d4")
    |> Arrange.game_turn(:white)
    |> Arrange.game_move("d1c1")
    |> Arrange.game_move("e4d3")
    |> Assert.invalid_move()
  end

  test "validation - cannot en passant if not on correct rank" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |   k    | 8
      7 |   pp   | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |  PP    | 2
      1 |   K    | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("d7d5")
    |> Arrange.game_move("c2d3")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(game, "d2d4")
    |> Arrange.game_move("e7d6")
    |> Assert.invalid_move()
  end
```

### Implementation
We could implement this a thousand different ways. The first one I did was to keep track of the history of game moves, that way I could check if the last move was a pawn advancing two squares in order to ensure the en passant is allowed. It was not bad, but it was overkill - the game history does not need to be part of the core Game structure, it feels more like a piece of metadata. We should only store the bare minimum of information that we need in order to evaluate the legality of the en passant.

After playing around with it, I stopped myself at storing a single integer `en_passant_file`. Whenever a pawn advances two squares at once, I would check what file it's on and set the value to `en_passant_file`. For  any other move, I would set it to `nil`, indicating en passant is not allowed on the next move.

I did decide to put that state in it's own `SpecialRules` struct. By the end of today's post that struct will have more state in it in order to accomodate for other special rules - such as castles.

```elixir
defmodule ExChess.SpecialRules do
  @type t() :: %__MODULE__{
          en_passant_file: non_neg_integer() | nil,
        }
  defstruct en_passant_file: nil

  def new(), do: %__MODULE__{}
end

defmodule ExChess.Game do
  ...
  @type t() :: %__MODULE__{
          board: Board.t(),
          special_rules: SpecialRules.t(),
        }
  @enforce_keys [:board]
  defstruct [:board, special_rules: SpecialRules.new()]
  ...
end
```

Now that we have that piece of state available as part of the `Game` struct, we can make use of it to extend out pawn's moves. Let's add a new parameter to `Game.valid_move?` - the special rules state. We can then use that to say: even if my basic set of moves for that piece does not allow this, fall back to checking out if any of the special moves allow it.
```elixir
  defp valid_move?(_board = %{}, _piece = nil, _move = %Move{}, _special_rules = %SpecialRules{}),
    do: false

  defp valid_move?(_board = %{}, _piece, _move = %Move{to: to}, _special_rules = %SpecialRules{})
       when to.file not in 0..7 or to.rank not in 0..7,
       do: false

  defp valid_move?(board = %{}, piece = %Piece{}, move = %Move{}, special_rules = %SpecialRules{}) do
    target_piece = Board.get(board, move.to)

    not Piece.same_color?(piece, target_piece) and
      patterns(piece)
      |> valid_move_pattern?(move) and
      (piece_rules_followed?(piece, move, board) or
         special_piece_rules_followed?(piece, move, board, special_rules)) # this is new
  end
```

Okay, so this new `Game.special_piece_rules_followed?` function takes in all the same parameters as `piece_rules_followed?` plus the special moves state. 

But what does the implementation look like?

First and foremost, to avoid allowing illegal moves, the default case for this new function will be `false`. Other than that we're going to say: if my current pawn is trying to take a piece on the `en_passant_file`, and is on the correct rank to do that, then the move is allowed. 

```elixir
  defp special_piece_rules_followed?(
         %Piece{type: :p, color: color},
         %Move{from: from, to: to},
         %{},
         %SpecialRules{
           en_passant_file: en_passant_file,
         }
       ),
       do:
         to.file == en_passant_file and to.file != from.file and
           from.rank == en_passant_rank(color)

  defp special_piece_rules_followed?(%Piece{}, %Move{}, %{}, %SpecialRules{}), do: false

  defp en_passant_rank(:white), do: 4
  defp en_passant_rank(:black), do: 3
```

Perfect, that's the new validation rules done. Now we need to take care of two more things: state, and state again.

First of all, we need to keep this new `en_passant_file` updated every time a move is made. Secondly, we need to make sure when en passant happens, the board is updated appropriately - the pawn that is being taken should be unset.
```elixir
  @spec move(t(), Move.t()) :: t() | error()
  def move(
        game = %__MODULE__{board: board, special_rules: special_rules},
        move = %Move{from: from, to: to}
      ) do
    piece = Board.get(board, from)

    if valid_move?(board, piece, move, special_rules) do
      updated_board =
        board
        |> maybe_unset_en_passant_target(piece, move) # new
        |> Board.set(to, piece)
        |> Board.unset(from)

      updated_special_rules = # new
        special_rules
        |> put_en_passant_file(piece, move)

      %__MODULE__{game | board: updated_board, special_rules: updated_special_rules}
    else
      {:error, :invalid_move}
    end
  end

  defp maybe_unset_en_passant_target(
         board = %{},
         _piece = %Piece{type: :p},
         _move = %Move{from: from, to: to}
       )
       when from.file != to.file do
    if Board.square_empty?(board, to) do
      Board.unset(board, Square.new(to.file, from.rank))
    else
      board
    end
  end

  defp maybe_unset_en_passant_target(board = %{}, _piece = %Piece{}, _move = %Move{}), do: board

  defp put_en_passant_file(special_rules = %SpecialRules{}, %Piece{type: :p}, %Move{
         from: from,
         to: to,
       })
       when abs(to.rank - from.rank) == 2,
       do: %SpecialRules{special_rules | en_passant_file: to.file}

  defp put_en_passant_file(special_rules = %SpecialRules{}, %Piece{}, %Move{}),
    do: %SpecialRules{special_rules | en_passant_file: nil}
```

And with that (plus some fixing of compiler errors, I'm sure you'll do just fine with that without me sharing the code in here) our new tests are all passing and the en passant move is implemented.

You'll notice that a design flaw is starting to emerge. There are now multiple places in the code, where we are performing very similar checks, in order to verify what type of move the pawn is making, and based on the type of move we run a different set of instructions.

This will become increasingly apparent soon, when we implement even more of chess' weird special moves. That's not something I will be dealing with just yet, but it will be quite soon.