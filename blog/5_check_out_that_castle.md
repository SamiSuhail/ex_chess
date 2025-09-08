# 5 - Check out that castle
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


## Agenda
Today we're implementing [castling](https://en.wikipedia.org/wiki/Castling). One of the intricacies of castling is that the king must not move through a checked square during the castling. Since we have not yet implemented [check](https://en.wikipedia.org/wiki/Check_(chess)), we will need to do that as well.

- 5.1 - [Check](https://en.wikipedia.org/wiki/Check_(chess))
  - 5.1.1 - Validation - check respected
- 5.2 - [Castling](https://en.wikipedia.org/wiki/Castling)
  - 5.2.1 - Kings are special
  - 5.2.2 - Validation - cannot castle if rook has moved
  - 5.2.3 - Validation - cannot castle if king has moved
  - 5.2.4 - Validation - cannot castle if path is not clear
  - 5.2.5 - Validation - cannot castle if square is under attack
  
## 5.1 - [Check](https://en.wikipedia.org/wiki/Check_(chess))
There are multiple approaches we can take when it comes to check, I've thought through a couple of them and have taken my pick, but as usual I want to start with the tests - you could think of something far better than what I have.

### 5.1.1 - Validation - check respected

#### Test
There are many edge cases that need to be tested. I am sure there are others I haven't thought of, but those are the ones I want to start with.
```elixir
defmodule ExChessTest.CheckTest do
  use ExUnit.Case
  alias ExChessTest.{Arrange, Assert}

  test "validation - check must be respected" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k       | 8
      7 |p      R| 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |P      r| 2
      1 |K       | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("h2h1")
    |> Arrange.game_move("a2a3")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(game, "h7h8")
    |> Arrange.game_move("a7a6")
    |> Assert.invalid_move()
  end

  test "validation - king cannot move into check" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k       | 8
      7 |p      R| 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |P      r| 2
      1 |K       | 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_move(game, "a1b2")
    |> Assert.invalid_move()

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("a8b7")
    |> Assert.invalid_move()
  end

  test "validation - cannot move pinned piece" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |kr     R| 8
      7 |        | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |        | 2
      1 |KR     r| 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_move(game, "b1b2")
    |> Assert.invalid_move()

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("b8b7")
    |> Assert.invalid_move()
  end

  test "validation - revealed checks should be respected" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k     NR| 8
      7 |p       | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |P       | 2
      1 |K     nr| 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("g1h3")
    |> Arrange.game_move("a2a3")
    |> Assert.invalid_move()

    # black
    Arrange.game_move(game, "g8h6")
    |> Arrange.game_move("a7a6")
    |> Assert.invalid_move()
  end

  test "taking the piece that is threatening your king is allowed" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |k      R| 8
      7 |p       | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |P       | 2
      1 |K      r| 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_move(game, "h8h1")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |k       | 8
    7 |p       | 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |        | 3
    2 |P       | 2
    1 |K      R| 1
      ----------
       abcdefgh
    """)

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_move("h1h8")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |k      r| 8
    7 |p       | 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |        | 3
    2 |P       | 2
    1 |K       | 1
      ----------
       abcdefgh
    """)
  end
end
```

#### Implementation
While implementing this, it actually caught a faulty test I had for the kings, where I was moving the king into check. If you want to see the fix for it, check out [the PR](https://github.com/SamiSuhail/ex_chess/pull/5)'s relevant commit `5.1`.

Another side effect of my work on this, is that I realized that I had a bug in `Game.list_legal_moves`. The pawns' legal moves never returned the last rank, even if the pawn is one rank away. This was happening because the call to `valid_move?` was never passing in a promotion type. You can see how I solved that below.

Okay, so first thing's first, `valid_move?` now needs to also validate that the move would not end with your king in check. 

```elixir
  defp check_respected?(
         board = %{},
         piece = %Piece{color: color},
         move = %Move{}
       ) do
    updated_board = update_board(board, piece, move)

    {king_square, _king} =
      Enum.find(updated_board, fn {_, curr_piece} ->
        curr_piece.type == :k and curr_piece.color == color
      end)

    king_attacked? =
      Enum.filter(updated_board, fn {_, curr_piece} -> curr_piece.color != color end)
      |> Enum.any?(fn {square, enemy_piece} ->
        valid_move?(
          updated_board,
          enemy_piece,
          Move.new(square, king_square),
          SpecialRules.new(),
          include_special_rules?: false,
          skip_move_detail?: true,
          skip_check?: true
        )
      end)

    not king_attacked?
  end

  defp update_board(board = %{}, piece = %Piece{}, move = %Move{}) do
    board
    |> maybe_unset_en_passant_target(piece, move)
    |> Board.set(move.to, piece)
    |> Board.unset(move.from)
    |> maybe_promote(move.to, move.detail, piece.color)
  end
```

So we start by making the move. To do that properly I've extracted the logic from `Game.move` to a new private `update_board` function.

With a now updated board, we need to find which square our king is on, and check if any of the opponent pieces are able to move to that square. However, we want to pass in some flags - when checking whether our king is under attack, we want to skip some of the rules.

`include_special_rules?: false` - We do not care about en passant or castling.
`skip_move_detail?: true` - We also do not care whether the move is a promotion or not.
`skip_check?: true` - As you know, we will now extend the `valid_move?` function by using this new `check_respected?` function. We do not however want to dive head first into an infinite recursion. This is why we are passing in a flag to say that when verifying if an opponent piece can attack our king, we do not care about checks on their own king.

Okay, now let's actually extend `valid_move?`.

First, we're adding a function head with the new optional keyword list. </br>
We then read the above mentioned keywords from that list, defaulting to the values expected for the `Game.move` call. You'll notice I've also added `skip_move_patterns?` - this is because `Game.list_legal_moves` has those as a starting point, so we do not need to validate the pattern, I'll let you decide whether you want to add that too.

We then use each of those flags to potentially skip some of the validations, and add in the new `check_respected?` call.

```elixir
  defp valid_move?(_board, _piece, _move, _special_rules, _opts \\ [])

  defp valid_move?(_board, _piece = nil, _move, _special_rules, _opts),
    do: false

  defp valid_move?(_board, _piece, _move = %Move{to: to}, _special_rules, _opts)
       when to.file not in 0..7 or to.rank not in 0..7,
       do: false

  defp valid_move?(
         board = %{},
         piece = %Piece{},
         move = %Move{},
         special_rules = %SpecialRules{},
         opts
       ) do
    target_piece = Board.get(board, move.to)

    skip_move_patterns? = Keyword.get(opts, :skip_move_patterns?, false)
    skip_move_detail? = Keyword.get(opts, :skip_move_detail?, false)
    skip_check? = Keyword.get(opts, :skip_check?, false)

    include_special_rules? = Keyword.get(opts, :include_special_rules?, true)

    not Piece.same_color?(piece, target_piece) and
      (skip_move_patterns? or
         patterns(piece)
         |> valid_move_pattern?(move)) and
      (skip_move_detail? or valid_move_detail?(move, piece)) and
      (piece_rules_followed?(piece, move, board) or
         (include_special_rules? and
            special_piece_rules_followed?(piece, move, board, special_rules))) and
      (skip_check? or check_respected?(board, piece, move))
  end
```

## 5.2 - [Castling](https://en.wikipedia.org/wiki/Castling)

*Castling is a move in chess. It consists of moving the king two squares toward a rook on the same rank and then moving the rook to the square that the king passed over. Castling is permitted only if neither the king nor the rook has previously moved; the squares between the king and the rook are vacant; and the king does not leave, cross over, or finish on a square attacked by an enemy piece. Castling is the only move in chess in which two pieces are moved at once.*

### 5.2.1 - Kings are special
Let's start by making sure that castling works when the king is on the starting position. 

#### Test
We start with two tests. The happy path, and one that asserts the king cannot castle once moved from the starting position.

First the happy path. We make sure both `move` and `list_legal_moves` work as expected. </br>
Then we assert that castling from a square different than the king's starting position is illegal.

The block of code is very vertical, but it is not particularly complex.
```elixir
  test "castling" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |r   k  r| 8
      7 |        | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |        | 2
      1 |R   K  R| 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_list_legal_moves(game, "e1")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r           k        r | 8
    7 |                        | 7
    6 |                        | 6
    5 |                        | 5
    4 |                        | 4
    3 |                        | 3
    2 |         [ ][ ][ ]      | 2
    1 | R    [ ][ ] K [ ][ ] R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)

    Arrange.game_move(game, "e1c1")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |r   k  r| 8
    7 |        | 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |        | 3
    2 |        | 2
    1 |  KR   R| 1
      ----------
       abcdefgh
    """)

    Arrange.game_move(game, "e1g1")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |r   k  r| 8
    7 |        | 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |        | 3
    2 |        | 2
    1 |R    RK | 1
      ----------
       abcdefgh
    """)

    # black
    game = Arrange.game_turn(game, :black)

    Arrange.game_list_legal_moves(game, "e8")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r    [ ][ ] k [ ][ ] r | 8
    7 |         [ ][ ][ ]      | 7
    6 |                        | 6
    5 |                        | 5
    4 |                        | 4
    3 |                        | 3
    2 |                        | 2
    1 | R           K        R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)

    Arrange.game_move(game, "e8c8")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |  kr   r| 8
    7 |        | 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |        | 3
    2 |        | 2
    1 |R   K  R| 1
      ----------
       abcdefgh
    """)

    Arrange.game_move(game, "e8g8")
    |> Assert.game_board("""
       abcdefgh
      ----------
    8 |r    rk | 8
    7 |        | 7
    6 |        | 6
    5 |        | 5
    4 |        | 4
    3 |        | 3
    2 |        | 2
    1 |R   K  R| 1
      ----------
       abcdefgh
    """)
  end

  test "validation - cannot castle when not on starting position" do
    game =
      Arrange.new_game()
      |> Arrange.game_board("""
         abcdefgh
        ----------
      8 |r      r| 8
      7 |    k   | 7
      6 |        | 6
      5 |        | 5
      4 |        | 4
      3 |        | 3
      2 |    K   | 2
      1 |R      R| 1
        ----------
         abcdefgh
      """)

    # white
    Arrange.game_list_legal_moves(game, "e2")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r                    r | 8
    7 |             k          | 7
    6 |                        | 6
    5 |                        | 5
    4 |                        | 4
    3 |         [ ][ ][ ]      | 3
    2 |         [ ] K [ ]      | 2
    1 | R       [ ][ ][ ]    R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)

    # black
    Arrange.game_turn(game, :black)
    |> Arrange.game_list_legal_moves("e7")
    |> Assert.legal_moves("""
        a  b  c  d  e  f  g  h
      --------------------------
    8 | r       [ ][ ][ ]    r | 8
    7 |         [ ] k [ ]      | 7
    6 |         [ ][ ][ ]      | 6
    5 |                        | 5
    4 |                        | 4
    3 |                        | 3
    2 |             K          | 2
    1 | R                    R | 1
      --------------------------
        a  b  c  d  e  f  g  h
    """)
  end
```

#### Implementation

First thing's first, we need to make sure the castles are now part of the king's possible movement patterns.
```diff
  @king_patterns [
    {-1, -1},
    {-1, 0},
    {-1, 1},
    {0, -1},
    {0, 1},
    {1, -1},
    {1, 0},
    {1, 1},
+   # castle
+   {-2, 0},
+   {2, 0},
  ]
```

We then need to make sure it is only allowed under the condition that the king is still on the starting position. This will be part of our set of special rules.

As you might remember, our `valid_move?` function currently checks:
```elixir
  piece_rules_followed?(piece, move, board) or
    (include_special_rules? and
      special_piece_rules_followed?(piece, move, board, special_rules))
```

This means we need to make sure the castles and all of their logic are validated in `special_piece_rules_followed?` - to do that, `piece_rules_followed?` must return false for the castles - let's add a new function head.

```elixir
  defp piece_rules_followed?(%Piece{type: :k}, %Move{from: from, to: to}, _board = %{}),
    do: abs(to.file - from.file) <= 1
```

And now to implement the real piece of validation - when the king is moving two files, we want to make sure it's `from` square is the starting position (`e1` and `e8` depending on the color).
```elixir
  defp special_piece_rules_followed?(
         %Piece{type: :k, color: color},
         %Move{from: from, to: to},
         %{},
         %SpecialRules{}
       )
       when abs(to.file - from.file) == 2 do
    king_starting_position?(color, from)
  end
  
  ...

  defp king_starting_position?(:white, %Square{file: 4, rank: 0}), do: true
  defp king_starting_position?(:black, %Square{file: 4, rank: 7}), do: true
  defp king_starting_position?(_, _), do: false
```

You will notice that with this code, already our `list_legal_moves` assertion is passing, but the `move` assertion fails, because the rook is not moving on the other side of the king. Let's fix that.

To ensure the board is updated correctly, let's extend our function.
```diff
  defp update_board(board = %{}, piece = %Piece{}, move = %Move{}) do
    board
    |> maybe_unset_en_passant_target(piece, move)
    |> Board.set(move.to, piece)
    |> Board.unset(move.from)
    |> maybe_promote(move.to, move.detail, piece.color)
+   |> maybe_castle(piece, move)
  end
```

If the piece is a king, and it is not moving 2 files over, then there is nothing to update. If however it is, then we need to grab the rook on the same side of the board, and move it over on the other side of the king.

In the case of any other piece, the board is not updated.
```elixir
  defp maybe_castle(board, %Piece{type: :k}, %Move{from: from, to: to})
       when abs(to.file - from.file) < 2,
       do: board

  defp maybe_castle(board, %Piece{type: :k, color: color}, %Move{to: to}) do
    {rook_from_file, rook_to_file} =
      case to.file do
        2 -> {0, 3}
        6 -> {7, 5}
      end

    Board.unset(board, Square.new(rook_from_file, to.rank))
    |> Board.set(Square.new(rook_to_file, to.rank), Piece.new(:r, color))
  end

  defp maybe_castle(board, _piece, _move), do: board
```

Our tests are now passing, and it's time to actually start tracking whether the rooks have moved.