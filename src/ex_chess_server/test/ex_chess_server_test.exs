defmodule ExChessServerTest do
  alias ExChessServerTest.{Arrange, Assert}
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
    white = Arrange.connected_client(server, :white)
    black = Arrange.connected_client(server, :black)

    assert is_pid(white)
    assert white != self()
    assert Process.alive?(white)

    assert is_pid(black)
    assert black != self()
    assert Process.alive?(black)
  end

  test "subscribe to events" do
    server = Arrange.server()

    Arrange.subscribe_events(server)
    |> Arrange.connected_client(:white)
    |> Arrange.disconnect_client()

    Assert.player_connected(:white)
    Assert.player_disconnected(:white)
  end

  test "players autosubscribe to events" do
    {server, white, black} = Arrange.server_with_clients()

    Arrange.disconnect_client(white)

    Assert.received(black, {:player_disconnected, :white})
  end

  test "when player reconnects twice then all three client processes remain active and reconnect event is published" do
    {server, white_1, black} = Arrange.server_with_clients()
    white_2 = Arrange.connected_client(server, :white)
    white_3 = Arrange.connected_client(server, :white)

    assert Process.alive?(white_1)
    assert Process.alive?(white_2)
    assert Process.alive?(white_3)
    Assert.received(white_1, {:player_reconnected, :white}, 2)
    Assert.received(black, {:player_reconnected, :white}, 2)
    Assert.received(white_2, {:player_reconnected, :white}, 1)
  end

  test "when player reconnects more than twice, oldest process gets killed " do
    {server, white_1, black} = Arrange.server_with_clients()
    white_2 = Arrange.connected_client(server, :white)
    white_3 = Arrange.connected_client(server, :white)
    white_4 = Arrange.connected_client(server, :white)
    white_5 = Arrange.connected_client(server, :white)

    assert not Process.alive?(white_1)
    assert not Process.alive?(white_2)
    assert Process.alive?(white_3)
    assert Process.alive?(white_4)
    assert Process.alive?(white_5)
  end

  test "player makes a move" do
    {server, white, _black} = Arrange.server_with_clients()

    Arrange.move(white, "a3")
    |> Assert.updated_board()
  end

  test "validation - player cannot move before connecting" do
    server = Arrange.server()
    black = Arrange.connected_client(server, :black)
    white = Arrange.client(:white)

    Arrange.move(white, "a3", server)
    |> Assert.error(:player_not_connected)
  end

  test "validation - player tries playing opponent's turn" do
    {server, _white, black} = Arrange.server_with_clients()

    Arrange.move(black, "a3")
    |> Assert.error(:opponent_turn)

    Arrange.move(black, "a6")
    |> Assert.error(:opponent_turn)
  end
end
