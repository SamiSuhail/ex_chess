defmodule ExChessServerTest do
  use ExUnit.Case
  doctest ExChessServer

  test "greets the world" do
    assert ExChessServer.hello() == :world
  end
end
