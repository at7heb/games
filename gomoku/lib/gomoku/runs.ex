defmodule Gomoku.Runs do
  @moduledoc """
  This module provides functions for implementing the RUNS (Run-Length Encoding)
  analysis for the Gomoku game.

  It takes a grid and recodes it in 4 ways: horizontally, vertically, and twice diagonally.
  Gomoku.Runs is opinionated; it doesn't worry about diagonals that are too close to corners.
  (aB and Ba are not relevant to winning or making a move, for example.)

  Gomoku.Intelligence will use the RUNS analysis to determine the best move.

  Gomoku.Board will use the RUNS analysis to determine if there is a winner.
  """

  # h, v, dr, dl mean horizontal, vertical, down right, and down left.
  # h_-,  v_-, dr_-, and dl_-lists will be a board.size-length list of tuples.
  # Each tuple comprises:
  #  * the starting coordinate of the line
  #  # the advance function
  #  * the go back function
  #  * the RUNS string: # and character: space, O, or X
  # the diagonal lists' length is board.size - (5 - 1) * 2 - 1, and are also lists of strings.
  # 5 in the formula above is the number of pieces in a row needed to win.
  # maybe we should delete the grid if it be not used.
  defstruct h_runs: [],
            v_runs: [],
            dr_runs: [],
            dl_runs: [],
            grid: %{}

  def new(%Gomoku.Board{} = board) do
    # Create a new RUNS struct with the board's grid and size
    %__MODULE__{
      h_runs: [],
      v_runs: [],
      dr_runs: [],
      dl_runs: [],
      grid: board.grid
    }
    |> make_runs(board.h_list, board.v_list)
  end

  def make_runs(%__MODULE__{} = runs, h_list, v_list) do
    # Create the runs for the grid

    {the_runs, _, _} =
      make_h_runs({runs, h_list, v_list})
      |> make_v_runs()
      |> make_dr_runs()
      |> make_dl_runs()

    the_runs
  end

  def make_h_runs({%__MODULE__{} = runs, h_list, v_list}) do
    # Create the horizontal Runs
    # create starting coordinates for each
    runs_list =
      Enum.map(
        v_list,
        fn v ->
          {:r000, v,
           Enum.map(
             h_list,
             fn h -> Map.get(runs.grid, "#{h}#{v}", " ") |> Gomoku.Board.one_character_color() end
           )
           |> Enum.join()}
        end
      )

    {%{runs | h_runs: runs_list}, h_list, v_list}
  end

  def make_v_runs({%__MODULE__{} = runs, h_list, v_list}) do
    # Create the vertical Runs
    runs_list =
      Enum.map(
        h_list,
        fn h ->
          {:r90, h,
           Enum.map(v_list, fn v ->
             Map.get(runs.grid, "#{h}#{v}", " ") |> Gomoku.Board.one_character_color()
           end)
           |> Enum.join()}
        end
      )

    {%{runs | v_runs: runs_list}, h_list, v_list}
  end

  def make_dr_runs({%__MODULE__{} = runs, h_list, v_list}) do
    # Create the down-right Runs
    {runs, h_list, v_list}
  end

  def make_dl_runs({%__MODULE__{} = runs, h_list, v_list}) do
    # Create the down-left Runs
    {runs, h_list, v_list}
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
