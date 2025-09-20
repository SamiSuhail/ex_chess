defmodule ExChess.SpecialRules do
  @type castling_rights() :: %{
          white_kingside: boolean(),
          white_queenside: boolean(),
          black_kingside: boolean(),
          black_queenside: boolean(),
        }
  @type t() :: %__MODULE__{
          en_passant_file: non_neg_integer() | nil,
          castling_rights: castling_rights(),
        }
  defstruct en_passant_file: nil,
            castling_rights: %{
              white_kingside: true,
              white_queenside: true,
              black_kingside: true,
              black_queenside: true,
            }

  def new(), do: %__MODULE__{}
end
