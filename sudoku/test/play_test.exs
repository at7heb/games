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
    IO.puts("------------------------- easy")
    Sudoku.Brain.Board.to_string(board) |> IO.puts()
    # assert Sudoku.Brain.Board.known_count(board) == 81
  end

  test "medium board" do
    IO.puts("-------------------------  medium")

    get_medium_initial_board()
    |> Sudoku.Brain.Board.new()
    |> Sudoku.Brain.Board.to_string()
    |> IO.puts()

    board = Sudoku.Brain.Play.play(get_medium_initial_board())
    IO.puts("-------------------------")
    Sudoku.Brain.Board.to_string(board) |> IO.puts()

    # assert Sudoku.Brain.Board.known_count(board) > 25
  end

  test "hard board" do
    IO.puts("------------------------- the hard one")

    get_hard_initial_board()
    |> Sudoku.Brain.Board.new()
    |> Sudoku.Brain.Board.to_string()
    |> IO.puts()

    board = Sudoku.Brain.Play.play(get_hard_initial_board())
    IO.puts("-------------------------")
    Sudoku.Brain.Board.to_string(board) |> IO.puts()
    {"hard board", Sudoku.Brain.Board.known_count(board)} |> dbg

    # assert Sudoku.Brain.Board.known_count(board) > 25
  end

  test "hard board2" do
    IO.puts("------------------------- the hard one")

    get_hard_initial_board2()
    |> Sudoku.Brain.Board.new()
    |> Sudoku.Brain.Board.to_string()
    |> IO.puts()

    board = Sudoku.Brain.Play.play(get_hard_initial_board2())
    IO.puts("-------------------------")
    Sudoku.Brain.Board.to_string(board, :short) |> IO.puts()
    {"hard board2", Sudoku.Brain.Board.known_count(board)} |> dbg
    # assert Sudoku.Brain.Board.known_count(board) > 25
  end

  def get_easy_initial_board() do
    " 9 1 8 4\n  375  89\n6     1\n3 96   2\n  79415\n 5   39 4\n  4     2\n56  824\n 3 4 9 5"
  end

  def get_medium_initial_board() do
    "       47\n 1   52\n7 42 1\n 679  3\n4   5   9\n  1  862\n   3 48 5\n  28   1\n34"
  end

  def get_hard_initial_board() do
    " 4 5    6\n  63\n 3   241\n  7  35\n    4\n  12  9\n 289   3\n     52\n3    6 7"
  end

  def get_hard_initial_board2() do
    " 4 5  3 6\n  63   5\n 3   241\n  7  35\n  3 4\n  125 9 3\n 289   3\n    352\n3   26 7"
  end

  def get_test_initial_board() do
    " 23456789"
  end
end
