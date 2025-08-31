# 4 - Chess is special

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
- 4.3 - Validation - pawn cannot promote if not on final square
- 4.4 - Castle
- 4.5 - Validation - cannot castle if path is not clear
- 4.6 - Validation - cannot castle if rook has moved
- 4.7 - Validation - cannot castle if king has moved