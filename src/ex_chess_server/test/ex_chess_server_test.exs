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

  test "if subscriber exits it is no longer subscribed" do
    server = Arrange.server()

    white =
      Arrange.connected_client(server, :white)
      |> Arrange.subscribe_client()

    Assert.subscribed(server, white)

    Arrange.disconnect_client(white)
    Assert.not_subscribed(server, white)
  end

  test "when player reconnects event is published and old process remains alive" do
    server = Arrange.server()
    Arrange.subscribe_events(server)
    white_1 = Arrange.connected_client(server, :white)
    white_2 = Arrange.connected_client(server, :white)

    assert Process.alive?(white_1)
    assert Process.alive?(white_2)
    Assert.player_reconnected(:white)
  end

  test "player move publishes event" do
    {server, white, _black} = Arrange.server_with_clients()
    Arrange.subscribe_events(server)

    Arrange.move(white, "a3")

    Assert.player_move(:white)
  end

  test "validation - player cannot move before connecting" do
    server = Arrange.server()
    Arrange.connected_client(server, :black)
    white = Arrange.client(server, :white)
    Arrange.subscribe_events(server)

    Arrange.move(white, "a3")
    |> Assert.error(:player_not_connected)

    Assert.no_event()
  end

  test "validation - player cannot move before both players have connected" do
    server = Arrange.server()
    white = Arrange.connected_client(server, :white)
    Arrange.subscribe_events(server)

    Arrange.move(white, "a3")
    |> Assert.error(:waiting_for_opponent)

    Assert.no_event()
  end

  test "validation - cannot play instead of opponent" do
    {server, _white, black} = Arrange.server_with_clients()
    Arrange.subscribe_events(server)

    Arrange.move(black, "a3")
    |> Assert.error(:opponent_turn)

    Arrange.move(black, "a6")
    |> Assert.error(:opponent_turn)

    Assert.no_event()
  end
end
