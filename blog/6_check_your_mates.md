# 6 - Check your mates

This blog post is part of a series that will be walking you through the process of building a production-ready chess application using Elixir.

Each blog post is a separate PR in [the github repository](https://github.com/SamiSuhail/ex_chess), and each section of the blog post with the relevant code is a commit in that PR.

To look at the code, check out [this PR](https://github.com/SamiSuhail/ex_chess/pull/5).

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
- 4 - [Pawns are special](TODO)
  - 4.1 - En passant
  - 4.2 - Promotion
  - 4.3 - Validation - pawn cannot advance to final rank without promoting
  - 4.4 - Validation - pawn cannot promote to king or pawn
  - 4.5 - Validation - pawn cannot promote if not on final square
- 5 - [Check out that castle](TODO)
  - 5.1 - [Check](https://en.wikipedia.org/wiki/Check_(chess))
    - 5.1.1 - Validation - check respected
  - 5.2 - [Castling](https://en.wikipedia.org/wiki/Castling)
    - 5.2.1 - Kings are special
    - 5.2.2 - Validation - cannot castle if rook has moved
    - 5.2.3 - Validation - cannot castle if king has moved
    - 5.2.4 - Validation - cannot castle if path is not clear
    - 5.2.5 - Validation - cannot castle if square is under attack
- 5.5 - [Make it pretty (an Elixir refactoring story)](TODO)
  - I - Don't Over-Repeat Yourself
  - II - No gods 'round 'ere
  - III - Idolize idioms
  - IV - Understand units
  
## Agenda
Today is all about checkmates, stalemates, and all your other mates.

At first we're just going to implement turn validation as it's something we somewhat overlooked earlier, it won't take us long.

The meat today is split into 5 parts - one for each possible game completion scenario. 

- 6.0 - Validation - same color can not move twice in a row
- 6.1 - Checkmate
- 6.2 - Stalemate
- 6.3 - Insufficient material
- 6.4 - Threefold repetition
- 6.5 - 50-move rule
- 6.6 - Resignation

Before we start I want to say a few words about performance. 

Let's start with the status quo.
```diff
- map for board representation
- naive approach for square under attack detection
- redundant computations when verifying for collision during list_legal_moves for linear pieces (:b, :r, :q)
+ short circuiting move validation on first invalid rule (no wasted CPU time)
+ all state for rules dependent on previous moves is pre-computed to avoid redundant iterations through the move history
+ hardly any other redundant computations other than the ones mentioned above
```

I've been quite performance aware during the development process, but I am also trying to not optimise prematurely. Today is the exact same, before I've even started I can already think of a couple of places where we can optimize for both time and space, but I also won't put too much effort into optimizing where that proves cumbersome.

There will be a blog post entirely focused on performance later on, that is when we'll be getting into the nitty gritty.

## 6.0 - Validation - same color can not move twice in a row
This is just something I forgot to implement earlier and I noticed it recently. Let's go through it, shouldn't be more than a couple of lines.

### Test
```elixir
  test "invalid move - cannot move same color piece twice in a row" do
    Arrange.new_game()
    |> Arrange.game_move("a2a4")
    |> Arrange.game_move("b2b4")
    |> Assert.invalid_move()
  end
```

### Implementation
First of all, there is a new piece of state we need to track for the Game struct, we'll call it `color_at_play` with a default value of `:white`.
```diff
  @type t() :: %__MODULE__{
+         color_at_play: Piece.color(),
          board: Board.t(),
          special_rules: SpecialRules.t(),
        }
- @enforce_keys [:board, :special_rules]
- defstruct [:board, :special_rules]
+ @enforce_keys [:color_at_play, :board, :special_rules]
+ defstruct [:color_at_play, :board, :special_rules]

  @spec new() :: t()
  def new(),
    do: %__MODULE__{
+     color_at_play: :white,
      board: Board.new(),
      special_rules: SpecialRules.new(),
    }
```

We now need to make sure that gets updated after every move.
```elixir
defmodule ExChess.Game do
  ...
  @spec move(t(), Move.t()) :: t() | :error
  def move(
        color_at_play: color_at_play,
        ...
      ) do
    with ... do # valid move
      %__MODULE__{
        game
        | ...,
          color_at_play: Piece.flip_color(color_at_play),
      }
    else
      ...
    end
  end
end

defmodule ExChess.Piece do
  ...
  @spec flip_color(color()) :: color()
  def flip_color(:white), do: :black
  def flip_color(:black), do: :white
end
```

And the last step is to ensure the color at play is also validated.

All we need is to update `Validators.Basic` - let's add a function head.
```elixir
  def valid?(%MoveContext{pieces: {%Piece{color: piece_color}, _}, color_at_play: color_at_play})
      when piece_color != color_at_play,
      do: false
```

Well, that and some compiler errors, but I won't bore you with those. Our new test is now passing. Let's get to the fun bit now.

## 6.1 - Checkmate
The classic way of beating your opponent - put the opponent's king in check, and ensure they have no possible move that would end with their king out of harm's way.

### Test
```elixir
  test "checkmate" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |       k| 8
      7 | R      | 7
      6 |R       | 6
      5 |pp      | 5
      4 |PP      | 4
      3 |r       | 3
      2 | r      | 2
      1 |       K| 1
        ----------
         abcdefgh
      """)

    Arrange.game_move(game, "a6a8")
    |> Assert.checkmate(:white)

    Arrange.game_turn(game, :black)
    |> Arrange.game_move("a3a1")
    |> Assert.checkmate(:black)
  end
```

### Implementation
Okay this is an interesting decision we need to make - how do we signal to the software using our library that the game is complete.

Do we just add additional state to the `Game` struct and rely on 


- 6.2 - Stalemate
- 6.3 - Insufficient material
- 6.4 - Threefold repetition
- 6.5 - 50-move rule
- 6.6 - Resignation