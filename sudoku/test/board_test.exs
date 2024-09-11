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
    r = Sudoku.Brain.Board.row_for({vert, horz})
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
    r = Sudoku.Brain.Board.big_square_for({vert, horz})
    horizontals = Enum.map(r, &elem(&1, 1)) |> Enum.uniq()
    verticals = Enum.map(r, &elem(&1, 0)) |> Enum.uniq()
    assert length(horizontals) == 3
    assert length(verticals) == 3
    assert length(r) == 8
    refute {vert, horz} in r
  end

  test "transposing g in board" do
    board = make_random_board()
    coords = Enum.map(1..600, fn _x -> {:rand.uniform(9), :rand.uniform(9)} end)

    transposed_board = Sudoku.Brain.Board.transpose(board)

    test_result =
      Enum.map(coords, fn {v, h} ->
        # {{v, h}, Sudoku.Brain.Board.at(board, {v, h}),
        #  Sudoku.Brain.Board.at(transposed_board, {v, h})}
        # |> dbg

        Sudoku.Brain.Board.at(board, {v, h}) == Sudoku.Brain.Board.at(transposed_board, {h, v})
      end)

    assert Enum.all?(test_result)
  end

  test "update known" do
    board = Sudoku.Brain.Board.new("1")
    assert Sudoku.Brain.Board.known_count(board) == 1
    assert Sudoku.Brain.Board.count_at(board, {2, 2}) == 9
    board2 = Sudoku.Brain.Board.update_known(board)
    assert Sudoku.Brain.Board.count_at(board2, {2, 2}) == 8
    assert Sudoku.Brain.Board.count_at(board2, {1, 2}) == 8
    assert Sudoku.Brain.Board.count_at(board2, {2, 1}) == 8
    assert Sudoku.Brain.Board.count_at(board2, {9, 9}) == 9
    board3 = Sudoku.Brain.Board.new("12345678")
    board4 = Sudoku.Brain.Board.update_known(board3)
    assert Sudoku.Brain.Board.count_at(board4, {1, 9}) == 1
    assert Sudoku.Brain.Board.count_at(board4, {2, 1}) == 6
    assert Sudoku.Brain.Board.count_at(board4, {7, 8}) == 8

    board5 = Sudoku.Brain.Board.update_known(board4)
    assert Sudoku.Brain.Board.count_at(board5, {1, 9}) == 1
    assert Sudoku.Brain.Board.count_at(board5, {2, 1}) == 6
    assert Sudoku.Brain.Board.count_at(board5, {7, 8}) == 8
    assert Sudoku.Brain.Board.count_at(board5, {9, 9}) == 8
  end

  def get_easy_initial_board() do
    " 9 1 8 4\n  375  89\n6     1\n3 96   2\n  79415\n 5   39 4\n  4     2\n46  824\n 3 4 9 5"
  end

  def make_random_board() do
    rows =
      for _vert <- 1..9,
          do: for(_horz <- 1..9, do: :rand.uniform(9) |> Integer.to_string()) |> Enum.join()

    Sudoku.Brain.Board.new(rows |> Enum.join("\n"))
  end
end
