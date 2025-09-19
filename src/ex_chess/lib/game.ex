defmodule ExChess.Game do
  alias ExChess.Game.{
    Validators,
    MoveContext,
    State.SpecialRulesManager,
    State.BoardManager,
    PieceTargets
  }

  alias ExChess.{SpecialRules, Board, Move, Square}

  @type t() :: %__MODULE__{
          board: Board.t(),
          special_rules: SpecialRules.t(),
        }
  @enforce_keys [:board]
  defstruct [:board, special_rules: SpecialRules.new()]

  @spec new() :: t()
  def new(),
    do: %__MODULE__{
      board: Board.new(),
    }

  @spec move(t(), Move.t()) :: t() | :error
  def move(
        game = %__MODULE__{board: board, special_rules: special_rules},
        move = %Move{}
      ) do
    with piece = Board.get(board, move.from),
         true <- Validators.Promotion.valid?(piece, move),
         {:ok, move_type, updated_board} <- evaluate_move(move, piece, board, special_rules),
         updated_special_rules = SpecialRulesManager.update(special_rules, piece, move, move_type) do
      %__MODULE__{game | board: updated_board, special_rules: updated_special_rules}
    else
      _ -> :error
    end
  end

  @spec list_legal_moves(t(), Square.t()) :: [Square.t()]
  def list_legal_moves(
        %__MODULE__{board: board, special_rules: special_rules},
        from_square = %Square{}
      ) do
    piece = Board.get(board, from_square)

    PieceTargets.get(piece, from_square)
    |> Enum.filter(fn to_square ->
      move = Move.new(from_square, to_square)
      match?({:ok, _, _}, evaluate_move(move, piece, board, special_rules))
    end)
  end

  defp evaluate_move(move, piece, board, special_rules) do
    with move_context = MoveContext.new(board, move, piece, special_rules),
         true <- Validators.Basic.valid?(move_context),
         normal_moves_result = Validators.NormalMoves.verify(move_context),
         {:ok, move_type} <-
           normal_moves_result || Validators.SpecialMoves.verify(move_context),
         updated_board = BoardManager.update(board, piece, move, move_type),
         false <- Validators.SquareUnderAttack.king?(updated_board, piece.color) do
      {:ok, move_type, updated_board}
    else
      _ -> :error
    end
  end
end
