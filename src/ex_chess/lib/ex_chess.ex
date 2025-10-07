defmodule ExChess do
  alias ExChessCore.{
    MoveContext,
    State.GameManager,
    MoveEvaluation,
    MoveGeneration
  }

  alias ExChess.{Game, Board, Move, Square, Piece}

  @spec start_game() :: Game.t()
  def start_game(), do: Game.new()

  @spec move(Game.t(), Move.t()) :: Game.t() | :error
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
  def claim_draw(%Game{halfmove_clock: halfmove_clock}) when halfmove_clock < 100, do: :error
  def claim_draw(game = %Game{}), do: %Game{game | status: {:tie, :fifty_move_rule}}

  @spec resign(Game.t()) :: Game.t() | :error
  def resign(%Game{status: status}) when status != :continue, do: :error

  def resign(game = %Game{active_color: active_color}),
    do: %Game{game | status: {Piece.flip_color(active_color), :resignation}}
end
