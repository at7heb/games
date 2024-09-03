defmodule PlayTest do
  use ExUnit.Case
  doctest Sudoku.Brain.Play

  test "can play" do
    board = Sudoku.Brain.Play.play(get_test_initial_board())
    assert Sudoku.Brain.Board.known_count(board) == 9
    # IO.puts("-------------------------")
    # Sudoku.Brain.Board.to_string(board) |> IO.puts()
  end

  test "easy board" do
    # IO.puts("-------------------------")

    # get_easy_initial_board()
    # |> Sudoku.Brain.Board.new()
    # |> Sudoku.Brain.Board.to_string()
    # |> IO.puts()

    board = Sudoku.Brain.Play.play(get_easy_initial_board())
    # IO.puts("-------------------------")
    # Sudoku.Brain.Board.to_string(board) |> IO.puts()

    assert Sudoku.Brain.Board.known_count(board) == 81
  end

  def get_easy_initial_board() do
    " 9 1 8 4\n  375  89\n6     1\n3 96   2\n  79415\n 5   39 4\n  4     2\n56  824\n 3 4 9 5"
  end

  def get_test_initial_board() do
    " 23456789"
  end
end
