defmodule Gomoku.Intelligence do
  @moduledoc """
  This module provides functions for implementing the intelligence
  and decision-making logic for the Gomoku game.
  """

  # Define your functions and logic here

  def make_move(%Gomoku.Board{} = board) do
    # Implement the logic for making a move
    # This is a placeholder implementation
    # Replace with actual logic to determine the move
    Gomoku.Rle.new(board)
    |> dbg

    row = Enum.random(board.v_list)
    col = Enum.random(board.h_list)
    new_square = "#{col}#{row}"

    new_board =
      Gomoku.Board.validate_selection(board, new_square)
      |> case do
        :ok ->
          # Update the board with the move
          IO.puts("Intelligent move: #{new_square} by player #{board.current_player}")
          Gomoku.Board.update_board(board, new_square)

        {:error, reason} ->
          IO.puts("Invalid move: #{new_square} because #{reason}")
          # Retry or handle the error as needed
          make_move(board)
      end

    Gomoku.Rle.new(new_board) |> dbg
    new_board
  end
end
