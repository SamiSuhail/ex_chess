defmodule ExChess.Game do
  alias ExChess.{Board, Piece}

  @type status() ::
          :continue
          | {:win, Piece.color(), :checkmate | :resignation}
          | {:tie,
             :stalemate
             | :insufficient_material
             | :threefold_repetition
             | :fivefold_repetition
             | :fifty_move_rule
             | :seventy_five_move_rule}

  @type en_passant_file() :: non_neg_integer() | nil
  @type halfmove_clock() :: non_neg_integer()

  @type castling_rights() :: %{
          white_kingside?: boolean(),
          white_queenside?: boolean(),
          black_kingside?: boolean(),
          black_queenside?: boolean(),
        }

  @type repetition_history() :: %{{Piece.color(), non_neg_integer()} => pos_integer()}

  @type t() :: %__MODULE__{
          status: status(),
          active_color: Piece.color(),
          board: Board.t(),
          en_passant_file: en_passant_file(),
          halfmove_clock: halfmove_clock(),
          castling_rights: castling_rights(),
          repetition_history: repetition_history(),
          max_repetitions: pos_integer(),
          fullmove_number: pos_integer(),
        }
  @enforce_keys [
    :status,
    :active_color,
    :board,
    :en_passant_file,
    :castling_rights,
    :repetition_history,
    :max_repetitions,
    :halfmove_clock,
    :fullmove_number,
  ]
  defstruct [
    :status,
    :active_color,
    :board,
    :en_passant_file,
    :castling_rights,
    :repetition_history,
    :max_repetitions,
    :halfmove_clock,
    :fullmove_number,
  ]

  @spec new() :: t()
  def new(),
    do:
      new(
        :white,
        Board.new(),
        %{
          white_kingside?: true,
          white_queenside?: true,
          black_kingside?: true,
          black_queenside?: true,
        },
        nil
      )

  @spec new(
          Piece.color(),
          Board.t(),
          castling_rights() | nil,
          en_passant_file(),
          halfmove_clock()
        ) :: t()
  def new(
        active_color,
        board,
        castling_rights \\ nil,
        en_passant_file \\ nil,
        halfmove_clock \\ 0,
        fullmove_number \\ 1
      ) do
    %__MODULE__{
      status: :continue,
      active_color: active_color,
      board: board,
      en_passant_file: en_passant_file,
      castling_rights: castling_rights || empty_castling_rights(),
      halfmove_clock: halfmove_clock,
      fullmove_number: fullmove_number,
      repetition_history: %{
        {active_color, :erlang.phash2(board)} => 1,
      },
      max_repetitions: 1,
    }
  end

  @spec empty_castling_rights() :: castling_rights()
  def empty_castling_rights() do
    %{
      white_kingside?: false,
      white_queenside?: false,
      black_kingside?: false,
      black_queenside?: false,
    }
  end

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

defimpl Inspect, for: ExChess.Game do
  alias ExChess.{Fen, Visualization}

  def inspect(game = %ExChess.Game{}, _opts) do
    status =
      case game.status do
        :continue ->
          "*"

        {:white, _reason} ->
          "1-0"

        {:black, _reason} ->
          "0-1"

        _ ->
          "1/2-1/2"
      end

    """
    STATUS: #{status}
    FEN: #{Fen.from_game(game)}
    BOARD:
    #{Visualization.Board.inspect(game.board)}
    """
  end
end
