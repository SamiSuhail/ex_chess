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
- 4.3 - Validation - pawn cannot advance to final rank without promoting
- 4.4 - Validation - pawn cannot promote to king or pawn
- 4.5 - Validation - pawn cannot promote if not on final square

## 4.1 - En passant
In case you haven't heard of [en passant](https://en.wikipedia.org/wiki/En_passant) - it's a special rule in chess that allows you to capture an opponents pawn with your own pawn even if it is not diagonally in front, under some conditions of course. I won't go into detail on what the conditions are but I absolutely recommend you look into it if it's not something you already know.

### Test
The tests are by no means comprehensive, there are so many edge cases that we might want to validate. I stopped myself to the happy path plus three validation error assertions.

I would usually implement the move first and the validations separately, but there was no good way of doing that without breaking some of our existing tests. So... brace yourself, this one is a bit more chunky.

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

Let's now use that in `Game.valid_move?`.
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

If the pawn is trying to take a piece on the `en_passant_file`, and is on the correct rank to do that, then the move is allowed. 

Also, to avoid allowing illegal moves, the default case for this new function will be `false`. 
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

## 4.2 - Promotion
[**Wikipedia**](https://en.wikipedia.org/wiki/Promotion_(chess))

*In chess, promotion is the replacement of a pawn with a new piece when the pawn is moved to its last rank.*

### Test
I've added a new `Arrange.game_promote` function which will be used when promoting a pawn in the tests. If you want to see the code for that, check out [the PR](https://github.com/SamiSuhail/ex_chess/pull/4) - although I am sure you can write it on your own, it's just syntactic sugar for `Game.move`.

```elixir
  test "promotion" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k       | 8
      7 |p  P    | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |P  p    | 2
      1 |K       | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_promote(game, "d7d8", :b)
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |k  B    | 8
    7 |p       | 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |        | 3
    2 |P  p    | 2
    1 |K       | 1
      ----------
       abcdefgh
    """)

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_promote("d2d1", :b)
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |k       | 8
    7 |p  P    | 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |        | 3
    2 |P       | 2
    1 |K  b    | 1
      ----------
       abcdefgh
    """)
  end
```
### Implementation
`Game.move` needs a new optional parameter - the piece type we are promoting to.

I decided to call it `detail` - a generic term. That will come in handy later.
```elixir
defmodule ExChess.Move do
  alias ExChess.Square

  @type promotion_detail() :: {:promotion, :q | :r | :b | :n}
  @type detail() :: nil | promotion_detail()
  @type t() :: %__MODULE__{
          from: Square.t(),
          to: Square.t(),
          detail: detail(),
        }
  @enforce_keys [:from, :to, :detail]
  defstruct [:from, :to, :detail]

  @spec new(Square.t(), Square.t(), detail()) :: t()
  def new(from, to, detail \\ nil),
    do: %__MODULE__{from: from, to: to, detail: detail}
end
```

In terms of actually ensuring the promotion occurs, it's a pretty simple change.
```elixir
  defp maybe_promote(board, square, _detail = {:promotion, piece_type}, piece_color),
    do: Board.set(board, square, Piece.new(piece_type, piece_color))

  defp maybe_promote(board, _square, _detail, _piece_color), do: board
```

```diff
      updated_board =
        board
        |> maybe_unset_en_passant_target(piece, move)
        |> Board.set(to, piece)
        |> Board.unset(from)
+       |> maybe_promote(to, detail, piece.color)
```

## 4.3 - Validation - pawn cannot advance to final rank without promoting
If a pawn advances to the final rank, a promotion is required.

### Test
```elixir
  test "validation - cannot advance to final rank without promoting" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k       | 8
      7 |p  P    | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |P  p    | 2
      1 |K       | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_move(game, "d7d8")
    |> Assert.invalid_move()

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("d2d1")
    |> Assert.invalid_move()
  end
```

### Implementation
First of all, `Game.valid_move?` needs to make an additional check.
```diff
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
+     valid_move_detail?(move, piece) and
      (piece_rules_followed?(piece, move, board) or
         special_piece_rules_followed?(piece, move, board, special_rules))
  end
```

All we need for now, is to make sure if it is the final rank that the pawn is advancing to, then a promotion has been specified.
```elixir
  defp valid_move_detail?(%Move{to: to, detail: detail}, %Piece{type: :p})
       when to.rank in [0, 7] do
    case detail do
      {:promotion, _piece_type} -> true
      _ -> false
    end
  end

  defp valid_move_detail?(%Move{}, %Piece{}), do: true
```

With that our tests are now green.

## 4.4 - Validation - pawn cannot promote to king or pawn
Not all piece types are valid for promotions. That needs to be validated.

### Test
```elixir
  test "validation - cannot promote to king or pawn" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k       | 8
      7 |p  P    | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |P  p    | 2
      1 |K       | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_promote(game, "d7d8", :k)
    |> Assert.invalid_move()

    Arrange.game_promote(game, "d7d8", :p)
    |> Assert.invalid_move()

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_promote("d2d1", :k)
    |> Assert.invalid_move()

    Arrange.game_turn(game, :black)
    |> Arrange.game_promote("d2d1", :p)
    |> Assert.invalid_move()
  end
```

### Implementation
A minor upgrade to `Game.valid_move_detail?`.
```elixir
  @valid_pawn_promotion_types [:q, :r, :b, :n]
  defp valid_move_detail?(%Move{to: to, detail: detail}, %Piece{type: :p})
       when to.rank in [0, 7] do
    case detail do
      {:promotion, piece_type} -> piece_type in @valid_pawn_promotion_types
      _ -> false
    end
  end
```

## 4.5 - Validation - pawn cannot promote if not on final square
Pretty self explanatory.

### Test
```elixir
  test "validation - pawn cannot promote if not on final square" do
    # white
    Arrange.new_game()
    |> Arrange.game_promote("a2a3", :q)
    |> Assert.invalid_move()

    # black
    Arrange.new_game()
    |> Arrange.game_move("a2a3")
    |> Arrange.game_promote("a7a6", :q)
    |> Assert.invalid_move()
  end
```

### Implementation
All we need to do is add a function head to `Game.valid_move_detail?` for all other pawn moves ensuring the `detail` is `nil`.
```diff
  @valid_pawn_promotion_types [:q, :r, :b, :n]
  defp valid_move_detail?(%Move{to: to, detail: detail}, %Piece{type: :p})
       when to.rank in [0, 7] do
    case detail do
      {:promotion, piece_type} -> piece_type in @valid_pawn_promotion_types
      _ -> false
    end
  end

+ defp valid_move_detail?(%Move{detail: detail}, %Piece{type: :p}), do: is_nil(detail)

  defp valid_move_detail?(%Move{}, %Piece{}), do: true
```

## Conclusion
Alright then, we're done with our pawns' special moves, quite the journey.

I mentioned earlier about a refactor being pretty iminnent at this point. I do believe that postponing it a tad bit more will be beneficial though - let's instead continue with some more special moves.

### Agenda
The next step will be implementing [castling](https://en.wikipedia.org/wiki/Castling). One of the intricacies of castling is that the king must not be moving through a checked square during the castling. Since we have not yet implemented [check](https://en.wikipedia.org/wiki/Check_(chess)), we will need to do that as well.

- 5 - Check out that castle
  - 5.1 - Castle
  - 5.2 - Validation - cannot castle if rook has moved
  - 5.3 - Validation - cannot castle if king has moved
  - 5.4 - Validation - cannot castle if path is not clear
  - 5.5 - Validation - check respected
  - 5.6 - Validation - cannot castle if square is under attack