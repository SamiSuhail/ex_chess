defmodule ExChessTest.KingTest do
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
      4 |   K    | 4
      3 |        | 3
      2 |        | 2
      1 |        | 1
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
      6 |        | 6
      5 |  ppp   | 5
      4 |   K    | 4
      3 |  ppp   | 3
      2 |        | 2
      1 |        | 1
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
      |> Assert.legal_moves(["c3", "c4", "c5", "d3", "d5", "e3", "e4", "e5"])
    end
  end
end
