defmodule ExChessCore.MoveContext do
  alias ExChess.{Game, Board, Move, Square, Piece}

  @type move_type_king_special() :: :castle_kingside | :castle_queenside
  @type move_type_pawn_special() :: :en_passant

  @type move_type_special() :: move_type_king_special() | move_type_pawn_special()

  @type move_type_pawn_basic() :: :take | :advance_one | :advance_two
  @type move_type_basic() :: move_type_pawn_basic() | nil

  @type move_type() :: move_type_basic() | move_type_special()

  @type pieces() :: {Piece.t() | nil, Piece.t() | nil}
  @type error() :: {:out_of_bounds, %{}}
  @type t() :: %__MODULE__{
          color: Piece.color(),
          board: Board.t(),
          square: Square.t(),
          target_square: Square.t(),
          square_shift: {file_shift :: integer(), rank_shift :: integer()},
          # optional
          valid?: nil | boolean(),
          game_status: nil | Game.status(),
          enemy_color: nil | Piece.color(),
          en_passant_file: nil | Game.en_passant_file(),
          castling_rights: nil | Game.castling_rights(),
          repetition_history: nil | Game.repetition_history(),
          max_repetitions: nil | pos_integer(),
          halfmove_clock: nil | Game.halfmove_clock(),
          fullmove_number: pos_integer(),
          promotion: Move.promotion(),
          error: nil | error(),
          piece: nil | Piece.type(),
          target_piece: nil | Piece.type(),
          move_type: nil | move_type(),
          updated_board: nil | Board.t(),
        }

  # required keys are based on the minimum number of fields needed to validate if the king is under attack
  @enforce_keys [
    :color,
    :board,
    :square,
    :target_square,
    :square_shift,
  ]
  defstruct [
    :color,
    :board,
    :square,
    :target_square,
    :square_shift,
    # optional
    :valid?,
    :game_status,
    :enemy_color,
    :en_passant_file,
    :castling_rights,
    :repetition_history,
    :max_repetitions,
    :halfmove_clock,
    :fullmove_number,
    :promotion,
    :error,
    :piece,
    :target_piece,
    :move_type,
    :updated_board,
  ]

  def new(
        %Game{
          status: game_status,
          active_color: color,
          board: board,
          en_passant_file: en_passant_file,
          castling_rights: castling_rights,
          repetition_history: repetition_history,
          max_repetitions: max_repetitions,
          halfmove_clock: halfmove_clock,
          fullmove_number: fullmove_number,
        },
        %Move{
          from: from,
          to: to,
          promotion: promotion,
        }
      ) do
    %__MODULE__{
      valid?: true,
      game_status: game_status,
      color: color,
      enemy_color: Piece.flip_color(color),
      board: board,
      en_passant_file: en_passant_file,
      castling_rights: castling_rights,
      repetition_history: repetition_history,
      max_repetitions: max_repetitions,
      halfmove_clock: halfmove_clock,
      fullmove_number: fullmove_number,
      square: from,
      target_square: to,
      square_shift: Square.compare(from, to),
      promotion: promotion,
    }
  end

  @spec error(t(), atom(), map()) :: t()
  def error(move_context = %__MODULE__{}, code, payload \\ %{})
      when is_atom(code) and is_map(payload) do
    %__MODULE__{
      move_context
      | valid?: false,
        error: {code, payload},
    }
  end

  @spec put_move_type(t(), move_type()) :: t()
  def put_move_type(move_context = %__MODULE__{}, move_type) do
    %__MODULE__{move_context | move_type: move_type}
  end
end
