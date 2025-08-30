defmodule ExChessTest.KnightTest do
  use ExUnit.Case
  alias ExChessTest.{Arrange, Assert}

  @scenarios [
    {
      "default",
      """
         abcdefgh
        ----------
      8 |       k| 8
      7 |        | 7
      6 |        | 6
      5 |        | 5
      4 |   N    | 4
      3 |        | 3
      2 |        | 2
      1 |       K| 1
        ----------
         abcdefgh
      """
    },
    {
      "can jump over pieces",
      """
         abcdefgh
        ----------
      8 |       k| 8
      7 |        | 7
      6 |        | 6
      5 |  ppp   | 5
      4 |  pNp   | 4
      3 |  ppp   | 3
      2 |        | 2
      1 |       K| 1
        ----------
         abcdefgh
      """
    },
    {
      "taking",
      """
         abcdefgh
        ----------
      8 |       k| 8
      7 |        | 7
      6 |  p p   | 6
      5 | p   p  | 5
      4 |   N    | 4
      3 | p   p  | 3
      2 |  p p   | 2
      1 |       K| 1
        ----------
         abcdefgh
      """
    },
  ]

  for {scenario_name, board} <- @scenarios do
    @tag board: board
    test "list legal moves - #{scenario_name}", %{board: board} do
      Arrange.new_game()
      |> Arrange.game_board(board)
      |> Arrange.game_list_legal_moves("d4")
      |> Assert.legal_moves(["b3", "b5", "c2", "c6", "e2", "e6", "f3", "f5"])
    end
  end
end
