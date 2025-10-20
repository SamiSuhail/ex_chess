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

  ### Getting a piece from the board

      iex> game = ExChess.start_game()
      iex> square = ExChess.Square.new(0, 0)
      iex> ExChess.Board.get(game.board, square)
  %ExChess.Piece{type: :r, color: :white}

  ### Getting legal moves for a square

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

  alias ExChess.{Fen, Game, Board, Move, Square, Piece}

  @spec start_game(Fen.t() | nil) :: Game.t()
  def start_game(fen \\ nil)
  def start_game(nil), do: Game.new()
  def start_game(fen), do: Fen.to_game(fen)

  @spec move(Game.t(), Move.t() | San.t()) :: Game.t() | :error
  def move(game, move) when is_binary(move) do
    case San.parse_move(game, move) do
      :error -> :error
      {:ok, parsed_move} -> move(game, parsed_move)
    end
  end

  def move(%Game{status: game_status}, _move) when game_status != :continue, do: :error

  def move(
        game = %Game{},
        move = %Move{}
      ) do
    MoveContext.new(game, move)
    |> MoveEvaluation.run()
    |> GameManager.updated()
  end

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

  @spec claim_draw(Game.t()) :: Game.t() | :error
  def claim_draw(%Game{status: status}) when status != :continue, do: :error

  def claim_draw(game = %Game{halfmove_clock: halfmove_clock}) when halfmove_clock >= 100,
    do: %Game{game | status: {:tie, :fifty_move_rule}}

  def claim_draw(game = %Game{max_repetitions: max_repetitions}) when max_repetitions >= 3,
    do: %Game{game | status: {:tie, :threefold_repetition}}

  def claim_draw(%Game{}), do: :error

  @spec resign(Game.t()) :: Game.t() | :error
  def resign(%Game{status: status}) when status != :continue, do: :error

  def resign(game = %Game{active_color: active_color}),
    do: %Game{game | status: {Piece.flip_color(active_color), :resignation}}
end
