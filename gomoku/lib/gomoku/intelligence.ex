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
    runs = Gomoku.Runs.new(board)
    my_color = if board.current_player == :black, do: "X", else: "O"
    place = find_a_place(runs, "X")
    # IO.puts("Intelligent move: #{place} by player #{board.current_player}")

    new_board =
      Gomoku.Board.validate_selection(board, place)
      |> case do
        :ok ->
          # Update the board with the move
          IO.puts("Intelligent move: #{place} by player #{board.current_player}")
          Gomoku.Board.update_board(board, place)

        {:error, reason} ->
          IO.puts("Invalid move: #{place} because #{reason}")
          # Retry or handle the error as needed
          make_move(board)
      end

    # Gomoku.Runs.new(new_board) |> dbg
    new_board
  end

  def find_a_place(%Gomoku.Runs{} = _runs, :black = _my_color) do
    _offense_patterns = [
      ~r/ XXXX/,
      ~r/XXXX /,
      ~r/  XXX /,
      ~r/ XXX  /,
      ~r/ X XX /,
      ~r/ XX X /,
      ~r/  XX   /,
      ~r/    X  /,
      ~r/ X    /
    ]

    _defense_patterns = [
      ~r/ OOOO/,
      ~r/OOOO /,
      ~r/  OOO /,
      ~r/ OOO  /,
      ~r/ O OO /,
      ~r/ OO O /,
      ~r/  OO   /,
      ~r/    O  /,
      ~r/ O    /
    ]
  end

  def find_a_place(%Gomoku.Runs{} = _runs, :white = _my_color) do
    _offense_patterns = [
      ~r/ OOOO/,
      ~r/OOOO /,
      ~r/  OOO /,
      ~r/ OOO  /,
      ~r/ O OO /,
      ~r/ OO O /,
      ~r/  OO   /,
      ~r/    O  /,
      ~r/ O    /
    ]

    _defense_patterns = [
      ~r/ XXXX/,
      ~r/XXXX /,
      ~r/  XXX /,
      ~r/ XXX  /,
      ~r/ X XX /,
      ~r/ XX X /,
      ~r/  XX   /,
      ~r/    X  /,
      ~r/ X    /
    ]
  end
end
