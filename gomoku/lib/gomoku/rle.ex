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
  defstruct h_list: [],
            v_list: [],
            dr_list: [],
            dl_list: [],
            grid: %{}

  def new(%Gomoku.Board{} = board) do
    # Create a new RLE struct with the board's grid and size
    %__MODULE__{
      h_list: [],
      v_list: [],
      dr_list: [],
      dl_list: [],
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

  def make_h_rle(%__MODULE__{} = rle) do
    # Create the horizontal RLEs
    rle
  end

  def make_v_rle(%__MODULE__{} = rle) do
    # Create the vertical RLEs
    rle
  end

  def make_dr_rle(%__MODULE__{} = rle) do
    # Create the down-right RLEs
    rle
  end

  def make_dl_rle(%__MODULE__{} = rle) do
    # Create the down-left RLEs
    rle
  end
end
