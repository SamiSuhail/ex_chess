defmodule ExChessServerTest.Arrange do
  def server() do
    {:ok, pid} = ExChessServer.start()
    pid
  end
end
