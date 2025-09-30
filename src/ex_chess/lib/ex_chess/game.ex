defmodule ExChess.Game do
  alias ExChess.{Board, Piece}

  @type status() ::
          :continue
          | {:win, Piece.color(), :checkmate | :resignation}
          | {:tie, :stalemate | :insufficient_material | :threefold_repetition | :fifty_move_rule}

  @type en_passant_file() :: non_neg_integer() | nil
  @type halfmove_clock() :: non_neg_integer()

  @type castling_rights() :: %{
          white_kingside?: boolean(),
          white_queenside?: boolean(),
          black_kingside?: boolean(),
          black_queenside?: boolean(),
        }

  # todo: actual FEN?
  @type fen() :: non_neg_integer()
  @type repetition_history() :: %{{Piece.color(), fen()} => pos_integer()}

  @type t() :: %__MODULE__{
          status: status(),
          color_at_play: Piece.color(),
          board: Board.t(),
          en_passant_file: en_passant_file(),
          halfmove_clock: halfmove_clock(),
          castling_rights: castling_rights(),
          repetition_history: repetition_history(),
        }
  @enforce_keys [
    :status,
    :color_at_play,
    :board,
    :en_passant_file,
    :castling_rights,
    :repetition_history,
    :halfmove_clock,
  ]
  defstruct [
    :status,
    :color_at_play,
    :board,
    :en_passant_file,
    :castling_rights,
    :repetition_history,
    :halfmove_clock,
  ]

  @spec new() :: t()
  def new(),
    do: %__MODULE__{
      status: :continue,
      color_at_play: :white,
      board: Board.new(),
      en_passant_file: nil,
      castling_rights: %{
        white_kingside?: true,
        white_queenside?: true,
        black_kingside?: true,
        black_queenside?: true,
      },
      repetition_history: %{
        {:white, :erlang.phash2(Board.new())} => 1,
      },
      halfmove_clock: 0,
    }

  @spec increment_repetition_history(repetition_history(), Piece.color(), Board.t()) ::
          {repetition_history(), pos_integer()}
  def increment_repetition_history(repetition_history = %{}, color, board) do
    position_key = {color, :erlang.phash2(board)}
    count = Map.get(repetition_history, position_key, 0) + 1

    {
      Map.put(repetition_history, position_key, count),
      count
    }
  end
end
