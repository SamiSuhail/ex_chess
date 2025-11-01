defmodule ExChessServerTest do
  use ExUnit.Case
  doctest ExChessServer

  test "start a game server" do
    server = Arrange.server()

    assert is_pid(server)
    assert server != self()
    assert Process.alive?(server)
  end

  test "players connected" do
    server = Arrange.server()
    white = Arrange.connect_client(server, :white)
    black = Arrange.connect_client(server, :black)

    assert is_pid(white)
    assert white != self()
    assert Process.alive?(white)

    assert is_pid(black)
    assert black != self()
    assert Process.alive?(black)
  end

  test "player makes a move" do
    {server, white, _black} = Arrange.server_with_clients()

    Arrange.move(white, "a3")
    |> Assert.updated_board()
  end

  test "validation - player tries playing opponent's turn" do
    {server, _white, black} = Arrange.server_with_clients()

    Arrange.move(black, "a3")
    |> Assert.error(:opponent_turn)

    Arrange.move(black, "a6")
    |> Assert.error(:opponent_turn)
  end

  test "subscribe to disconnect events" do
    {server, white, _black} = Arrange.server_with_clients()

    Arrange.subscribe_disconnect_messages(server)

    Arrange.player_disconnect(white)

    assert_receive {:player_disconnected, :white}
    refute_receive {:player_disconnected, :black}
  end
end
