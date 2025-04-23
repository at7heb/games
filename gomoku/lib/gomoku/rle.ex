defmodule Gomoku.Rle do
  @moduledoc """
  This module provides functions for implementing the RLE (Run-Length Encoding)
  analysis for the Gomoku game.

  It takes a grid and recodes it in 4 ways: horizontally, vertically, and twice diagonally.
  Gomoku.Rle is opinionated; it doesn't worry about diagonals that are too close to corners.
  (aB and Ba are not relevant to winning or making a move, for example.)

  Gomoku.Intelligence will use the RLE analysis to determine the best move.

  Gomoku.Board will use the RLE analysis to determine if there is a winner.
  """

  # h, v, dr, dl mean horizontal, vertical, down right, and down left.
  # h_-,  v_-, dr_-, and dl_-lists will be a board.size-length list of tuples.
  # Each tuple comprises:
  #  * the starting coordinate of the line
  #  # the advance function
  #  * the go back function
  #  * the RLE string: # and character: space, O, or X
  # the diagonal lists' length is board.size - (5 - 1) * 2 - 1, and are also lists of strings.
  # 5 in the formula above is the number of pieces in a row needed to win.
  # maybe we should delete the grid if it be not used.
  defstruct h_runs: [],
            v_runs: [],
            dr_runs: [],
            dl_runs: [],
            grid: %{}

  def new(%Gomoku.Board{} = board) do
    # Create a new RLE struct with the board's grid and size
    %__MODULE__{
      h_runs: [],
      v_runs: [],
      dr_runs: [],
      dl_runs: [],
      grid: board.grid
    }
    |> make_rles(board.h_list, board.v_list)
  end

  def make_rles(%__MODULE__{} = rle, h_list, v_list) do
    # Create the RLEs for the grid
    {rle, h_list, v_list}
    |> make_h_rle()
    |> make_v_rle()
    |> make_dr_rle()
    |> make_dl_rle()
  end

  def make_h_rle({%__MODULE__{} = rle, h_list, v_list}) do
    # Create the horizontal RLEs
    # create starting coordinates for each
    runs = Enum.map(v_list, fn v -> {"#{v}A", scan_one(v, h_list, rle.grid)} end)
    {%{rle | h_runs: runs}, h_list, v_list}
  end

  def make_v_rle({%__MODULE__{} = rle, h_list, v_list}) do
    # Create the vertical RLEs
    runs = Enum.map(h_list, fn h -> {"#{h}a", scan_one(h, v_list, rle.grid)} end)
    {%{rle | v_runs: runs}, h_list, v_list}
  end

  def make_dr_rle({%__MODULE__{} = rle, h_list, v_list}) do
    # Create the down-right RLEs
    {rle, h_list, v_list}
  end

  def make_dl_rle({%__MODULE__{} = rle, h_list, v_list}) do
    # Create the down-left RLEs
    {rle, h_list, v_list}
  end

  def scan_one(fixed_coord, [first_scan | rest_of_scans], grid) do
    # Scan one row or column of the grid for runs of pieces
    initial_accumulator = [
      {1,
       Map.get(grid, Gomoku.Board.canonicalize(fixed_coord, first_scan), " ")
       |> Gomoku.Board.one_character_color()}
    ]

    Enum.reduce(rest_of_scans, initial_accumulator, fn scan, [{count, last_char} | rest] ->
      # Get the character at the current coordinate
      next_coordinate = Gomoku.Board.canonicalize(fixed_coord, scan)
      next_char = Map.get(grid, next_coordinate, " ") |> Gomoku.Board.one_character_color()
      #  if the character continues the run, increase count
      if next_char == last_char do
        [{count + 1, last_char} | rest]
      else
        # start new run
        [{1, next_char} | [{count, last_char} | rest]]
      end
    end)
    |> Enum.reverse()
    |> Enum.map(fn {count, char} -> "#{Integer.to_string(count, 32)}#{char}" end)
    |> Enum.join("")

    # |> dbg
  end
end
