defmodule GomokuTest do
  use ExUnit.Case
  doctest Gomoku

  test "greets the world" do
    assert Gomoku.hello() == :world
  end
end
