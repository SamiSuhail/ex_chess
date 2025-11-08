defmodule ExChess do
  @moduledoc """
  ExChess is a, although still primitive, comprehensive implementation of the chess game rules in Elixir.

  ## Examples

  ### Starting a game

      iex> ExChess.start_game()
      ...> |> ExChess.Visualization.game()
      "STATUS: * | FEN: rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

  ### Starting a game using FEN

      iex> ExChess.start_game("rnbqkb1r/pppppppp/5n2/8/8/5N2/PPPPPPPP/RNBQKB1R w KQkq - 2 2")
      ...> |> ExChess.Visualization.game()
      "STATUS: * | FEN: rnbqkb1r/pppppppp/5n2/8/8/5N2/PPPPPPPP/RNBQKB1R w KQkq - 2 2"

  ### Making a move

      iex> ExChess.start_game()
      ...> |> ExChess.move("Nf3")
      ...> |> ExChess.move("Nf6")
      ...> |> ExChess.Visualization.game()
      "STATUS: * | FEN: rnbqkb1r/pppppppp/5n2/8/8/5N2/PPPPPPPP/RNBQKB1R w KQkq - 2 2"

  ### Getting a piece from the board

      iex> game = ExChess.start_game()
      iex> square = ExChess.Square.new(0, 0)
      iex> ExChess.Board.get(game.board, square)
      %ExChess.Piece{type: :r, color: :white}

  ### Getting legal moves for a piece

      iex> ExChess.start_game()
      ...> |> ExChess.list_legal_moves(ExChess.Square.new(1, 1))
      [%ExChess.Square{file: 1, rank: 2}, %ExChess.Square{file: 1, rank: 3}]
  """

  alias ExChessCore.{
    MoveContext,
    State.GameManager,
    MoveEvaluation,
    MoveGeneration,
    San
  }

  alias ExChess.{Fen, Game, Player, Board, Move, Square, Piece}

  @doc """
  Instantiates a new `ExChess.Game`. An optional `fen` string can be passed in to start the game at a particular position.

  ## Examples

  ### Starting a game

      iex> ExChess.start_game()
      ...> |> ExChess.Visualization.game()
      "STATUS: * | FEN: rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

  ### Starting a game using FEN

      iex> ExChess.start_game("rnbqkb1r/pppppppp/5n2/8/8/5N2/PPPPPPPP/RNBQKB1R w KQkq - 2 2")
      ...> |> ExChess.Visualization.game()
      "STATUS: * | FEN: rnbqkb1r/pppppppp/5n2/8/8/5N2/PPPPPPPP/RNBQKB1R w KQkq - 2 2"
  """
  @spec start_game(Fen.t() | nil) :: Game.t()
  def start_game(fen \\ nil)
  def start_game(nil), do: Game.new()
  def start_game(fen), do: Fen.to_game(fen)

  @doc """
  Returns the updated `ExChess.Game` when the move is valid, and `:error` otherwise.

  ## Examples

  ### Making a move using SAN

      iex> ExChess.start_game()
      ...> |> ExChess.move("Nf3")
      ...> |> ExChess.move("Nf6")
      ...> |> ExChess.Visualization.game()
      "STATUS: * | FEN: rnbqkb1r/pppppppp/5n2/8/8/5N2/PPPPPPPP/RNBQKB1R w KQkq - 2 2"

  ### Making a move using structs

      iex> first_move = ExChess.Move.new(ExChess.Square.new(6, 0), ExChess.Square.new(5, 2))
      ...> second_move = ExChess.Move.new(ExChess.Square.new(6, 7), ExChess.Square.new(5, 5))
      ...> ExChess.start_game()
      ...> |> ExChess.move(first_move)
      ...> |> ExChess.move(second_move)
      ...> |> ExChess.Visualization.game()
      "STATUS: * | FEN: rnbqkb1r/pppppppp/5n2/8/8/5N2/PPPPPPPP/RNBQKB1R w KQkq - 2 2"

  ### Making an invalid move

      iex> ExChess.start_game()
      ...> |> ExChess.move("a2b3")
      :error

  ### Game already complete
      iex> ExChess.start_game()
      ...> |> ExChess.resign()
      ...> |> ExChess.move("h3")
      :error
  """
  @spec move(Game.t(), Move.t() | San.t()) :: Game.t() | :error
  def move(%Game{status: game_status}, _move) when game_status != :continue, do: :error

  def move(
        game = %Game{},
        move
      ) do
    case move_internal(game, move) do
      {updated_game, _player_diff} -> updated_game
      :error -> :error
    end
  end

  @doc """
  Returns a tuple of the updated `ExChess.Game` and the `ExChess.Player.diff()` representing the changes made to the player's state when the move is valid, and `:error` otherwise.

  Please refer to `ExChess.move/2` for more information and examples regarding the move functionality.

  The second element of the returned tuple contains the differences in the board and draw claimable status after the move has been made.
  It can be used together with `ExChess.Player.apply_diff/2` to efficiently update the player's view of the game state without needing to reconstruct or send the entire state from scratch.

  ## Examples

      iex> game = ExChess.start_game()
      iex> player = ExChess.Player.new(game)
      iex> {updated_game, player_diff} = ExChess.move_and_diff(game, "Nf3")
      iex> updated_player = ExChess.Player.apply_diff(player, player_diff)
      iex> updated_game.board == updated_player.board
      true
      iex> updated_game.active_color == updated_player.active_color
      true
      iex> updated_game.fullmove_number == updated_player.fullmove_number
      true
      iex> ExChess.Player.draw_claimable?(updated_game.halfmove_clock, updated_game.max_repetitions) == updated_player.draw_claimable?
      true
  """
  @spec move_and_diff(Game.t(), Move.t() | San.t()) :: {Game.t(), Player.diff()} | :error
  def move_and_diff(
        game = %Game{},
        move
      ) do
    move_internal(game, move)
  end

  defp move_internal(game, move) when is_binary(move) do
    case San.parse_move(game, move) do
      :error -> :error
      {:ok, parsed_move = %Move{}} -> move_internal(game, parsed_move)
    end
  end

  defp move_internal(game, move = %Move{}) do
    MoveContext.new(game, move)
    |> MoveEvaluation.run()
    |> GameManager.updated()
  end

  @doc """
  Lists all available target squares for the piece situated on `from_square`.

  ## Examples

  ### Getting legal moves for a piece

      iex> ExChess.start_game()
      ...> |> ExChess.list_legal_moves(ExChess.Square.new(1, 1))
      [%ExChess.Square{file: 1, rank: 2}, %ExChess.Square{file: 1, rank: 3}]
  """
  @spec list_legal_moves(Game.t(), Square.t()) :: [Square.t()]
  def list_legal_moves(
        %Game{
          active_color: active_color,
          board: board,
          en_passant_file: en_passant_file,
          castling_rights: castling_rights,
        },
        from_square = %Square{}
      ) do
    piece = Board.get(board, from_square)

    MoveGeneration.stream(
      active_color,
      board,
      en_passant_file,
      castling_rights,
      piece,
      from_square
    )
    |> Enum.to_list()
  end

  @doc """
  Allows the active player to claim a draw in case of either:
  - 50 move rule
  - threefold repetition

  ## Examples

  ### 50 move rule

      iex> ExChess.start_game("knn5/8/8/8/8/8/8/KNN5 w - - 101 90") # 101 halfmoves
      ...> |> ExChess.claim_draw()
      ...> |> ExChess.Visualization.status()
      "1/2-1/2"

  ### Threefold repetition

      iex> ExChess.start_game() # first occurence
      ...> |> ExChess.move("Nc3") |> ExChess.move("Nc6")
      ...> |> ExChess.move("Nb1") |> ExChess.move("Nb8") # second occurence
      ...> |> ExChess.move("Nc3") |> ExChess.move("Nc6")
      ...> |> ExChess.move("Nb1") |> ExChess.move("Nb8") # third occurence
      ...> |> ExChess.claim_draw()
      ...> |> ExChess.Visualization.status()
      "1/2-1/2"

  ### Draw unclaimable
      iex> ExChess.start_game()
      ...> |> ExChess.claim_draw()
      :error

  ### Game already complete
      iex> ExChess.start_game()
      ...> |> ExChess.resign()
      ...> |> ExChess.claim_draw()
      :error
  """
  @spec claim_draw(Game.t()) :: Game.t() | :error
  def claim_draw(%Game{status: status}) when status != :continue, do: :error

  def claim_draw(game = %Game{halfmove_clock: halfmove_clock}) when halfmove_clock >= 100,
    do: %Game{game | status: {:tie, :fifty_move_rule}}

  def claim_draw(game = %Game{max_repetitions: max_repetitions}) when max_repetitions >= 3,
    do: %Game{game | status: {:tie, :threefold_repetition}}

  def claim_draw(%Game{}), do: :error

  @doc """
  Returns the update `ExChess.Game` with the current active color's side having resigned and the opponent is declared the winner.

  If the game is already complete, this returns `:error`.

  ## Examples

  ### White resigns

      iex> ExChess.start_game()
      ...> |> ExChess.resign()
      ...> |> ExChess.Visualization.status()
      "0-1"

  ### Black resigns

      iex> ExChess.start_game()
      ...> |> ExChess.move("a3")
      ...> |> ExChess.resign()
      ...> |> ExChess.Visualization.status()
      "1-0"

  ### Game already complete
      iex> ExChess.start_game()
      ...> |> ExChess.resign()
      ...> |> ExChess.resign()
      :error
  """
  @spec resign(Game.t()) :: Game.t() | :error
  def resign(%Game{status: status}) when status != :continue, do: :error

  def resign(game = %Game{active_color: active_color}),
    do: %Game{game | status: {Piece.flip_color(active_color), :resignation}}
end
