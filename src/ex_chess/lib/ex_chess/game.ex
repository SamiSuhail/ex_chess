defmodule ExChess.Game do
  @moduledoc """
  The `ExChess.Game` struct is an aggregate of the entirety of the state required to keep track of the game, and evaluate all chess rules.
  """
  alias ExChess.{Board, Piece}

  @typedoc """
  The game status.

  `:continue` is the default state, it represents a game that is still in progress.
  `{Piece.color(), _reason}` is used when one of the players has been declared winner.
  `{:tie, _reason}` means the game ended in a draw.
  """
  @type status() ::
          :continue
          | {Piece.color(), :checkmate | :resignation}
          | {:tie,
             :stalemate
             | :insufficient_material
             | :threefold_repetition
             | :fivefold_repetition
             | :fifty_move_rule
             | :seventy_five_move_rule}

  @typedoc """
  The en passant file keeps track of any file where a pawn has advanced two squares and is vulnerable to en passant.
  This value is set regardless of whether another pawn is in position to attack.
  If the last halfmove was anything other than a pawn advancing two squares, the en passant file is `nil`.
  """
  @type en_passant_file() :: non_neg_integer() | nil

  @typedoc """
  The halfmove clock keeps track of the number of irreversible moves in a row that have occured. This is then used to
  evaluate whether or not the 50 move rule and/or the 75 move rule apply.
  """
  @type halfmove_clock() :: non_neg_integer()

  @typedoc """
  Keeps track of the number of fullmoves. A fullmove is incremented by 1 after every move by `:black`.
  """
  @type fullmove_number() :: pos_integer()

  @typedoc """
  Castling is only allowed when neither the rook nor the king have previously moved throughout the game.
  Each castle starts with a value of `true`, and whenever a king or rook is moved, the corresponding castles are set to `false`.
  """
  @type castling_rights() :: %{
          white_kingside?: boolean(),
          white_queenside?: boolean(),
          black_kingside?: boolean(),
          black_queenside?: boolean(),
        }

  @typedoc """
  This is used to keep count of all positions that have already been played, in order to evaluate the threefold/fivefold repetition rules.
  The map is reset any time an irreversible move is played, as that guarantees that position will never be repeated.

  The key is a tuple containing two elements: the active color and a hash of the board state, those two values are enough to
  identify each unique position. The values are of course the count of repetitions for said position.
  """
  @type repetition_history() :: %{{Piece.color(), non_neg_integer()} => pos_integer()}

  @typedoc """
  Keeps track of the maximum count present in the repetition history for easier evaluation of threefold/fivefold repetition.
  """
  @type max_repetitions() :: pos_integer()

  @typedoc """
  The `ExChess.Game` struct is an aggregate of the entirety of the state required to keep track of the game, and evaluate all chess rules.
  """
  @type t() :: %__MODULE__{
          status: status(),
          active_color: Piece.color(),
          board: Board.t(),
          en_passant_file: en_passant_file(),
          halfmove_clock: halfmove_clock(),
          castling_rights: castling_rights(),
          repetition_history: repetition_history(),
          max_repetitions: max_repetitions(),
          fullmove_number: fullmove_number(),
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

  @doc """
  Creates a new game with all the default state.

  ## Examples

      iex> ExChess.Game.new()
      ...> |> ExChess.Visualization.game()
      "STATUS: * | FEN: rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
  """
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

  @doc """
  Creates a new game.

  ## Examples

      iex> ExChess.Game.new(:white, ExChess.Fen.to_board("knn5/8/8/8/8/8/8/KNN5"), nil, 3, 40)
      ...> |> ExChess.Fen.from_game()
      "knn5/8/8/8/8/8/8/KNN5 w - d4 40 1"
  """
  @spec new(
          Piece.color(),
          Board.t(),
          castling_rights() | nil,
          en_passant_file(),
          halfmove_clock(),
          fullmove_number()
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

  @doc """
  Returns a map with all castling rights set to `false`.
  """
  @doc deprecated:
         "This is only used in two places and I am not yet sure I want to expose it in the public API."
  @spec empty_castling_rights() :: castling_rights()
  def empty_castling_rights() do
    %{
      white_kingside?: false,
      white_queenside?: false,
      black_kingside?: false,
      black_queenside?: false,
    }
  end
end

defimpl Inspect, for: ExChess.Game do
  alias ExChess.Visualization

  def inspect(game = %ExChess.Game{}, _opts), do: Visualization.game_full(game)
end
