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
    rle = Gomoku.Rle.new(board)
    my_color = if board.current_player == :black, do: "X", else: "O"
    place = find_a_place(rle, my_color)
    IO.puts("Intelligent move: #{place} by player #{board.current_player}")

    new_board =
      Gomoku.Board.validate_selection(board, place)
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

    # Gomoku.Rle.new(new_board) |> dbg
    new_board
  end

  def find_a_place(%__MODULE__{} = rle, my_color)
end
