defmodule BoardTest do
  use ExUnit.Case
  doctest Sudoku.Brain.Board

  test "can make a board" do
    b = Sudoku.Brain.Board.new()
    assert b != nil
    assert Sudoku.Brain.Board.known_count(b) == 0
  end

  test "can make board from text" do
    b = Sudoku.Brain.Board.new(get_easy_initial_board())
    assert b != nil
    assert Sudoku.Brain.Board.known_count(b) == 35
  end

  test "row for" do
    vert = :rand.uniform(9)
    horz = :rand.uniform(9)
    r = Sudoku.Brain.Board.row_for(vert, horz)
    horizontals = Enum.map(r, &elem(&1, 1)) |> Enum.uniq()
    verticals = Enum.map(r, &elem(&1, 0)) |> Enum.uniq()
    assert length(horizontals) == 8
    assert length(verticals) == 1
    assert length(r) == 8
    refute {vert, horz} in r
  end

  test "big square for" do
    vert = :rand.uniform(9)
    horz = :rand.uniform(9)
    r = Sudoku.Brain.Board.big_square_for(vert, horz)
    horizontals = Enum.map(r, &elem(&1, 1)) |> Enum.uniq()
    verticals = Enum.map(r, &elem(&1, 0)) |> Enum.uniq()
    assert length(horizontals) == 3
    assert length(verticals) == 3
    assert length(r) == 8
    refute {vert, horz} in r
  end

  def get_easy_initial_board() do
    " 9 1 8 4\n  375  89\n6     1\n3 96   2\n  79415\n 5   39 4\n  4     2\n46  824\n 3 4 9 5"
  end
end
