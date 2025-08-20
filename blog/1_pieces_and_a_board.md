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

## Conclusion

### Up next

