# 2 - Get pawned
This blog post is part of a series that will be walking you through the process of building a production-ready chess application using Elixir.

Each blog post is a separate PR in [the github repository](https://github.com/SamiSuhail/ex_chess), and each section of the blog post with the relevant code is a commit in that PR.

To look at the code, check out [this PR](https://github.com/SamiSuhail/ex_chess/pull/2).

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

## Agenda
Today sounds like it's all about pawns but it really isn't. If phase one was us laying the foundations, phase two is all about future-proofing. Pawns are just one of the things we need in order to achieve that.

- 2.1 - `Game.list_legal_moves(game, from_square)` 
- 2.2 - Extensive testing
- 2.3 - Pawns
  - 2.3.1 - Advancing
  - 2.3.2 - Advancing two squares
  - 2.3.3 - Validation - pawn cannot advance two squares after moving
  - 2.3.4 - Validation - pawn cannot advance if path is blocked
  - 2.3.5 - Taking
  - 2.3.6 - Validation - pawn cannot move diagonally when not taking
- 2.4 - Refactor - Movement types