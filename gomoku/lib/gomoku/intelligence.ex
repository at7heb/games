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
    # my_color = if board.current_player == :black, do: "X", else: "O"
    place = find_a_place(runs, board.current_player)
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

  @doc """
      find_a_place(runs, offense_patterns, defense_patterns)
      Regex.named_captures(~r/c(?<foo>d)/, "abcd")
      %{"foo" => "d"}
  """
  def find_a_place(%Gomoku.Runs{} = runs, :black = _my_color) do
    offense_patterns = [
      ~r/(?<b> )XXXX/,
      ~r/XXXX(?<b> )/,
      ~r/ (?<b> )XXX /,
      ~r/ XXX(?<b> ) /,
      ~r/ X(?<b> )XX /,
      ~r/ XX(?<b> )X /,
      ~r/  XX(?<b> )  /,
      ~r/   (?<b> )X  /,
      ~r/ X(?<b> )   /
    ]

    defense_patterns = [
      ~r/(?<b> )OOOO/,
      ~r/OOOO(?<b> )/,
      ~r/ (?<b> )OOO /,
      ~r/ OOO(?<b> ) /,
      ~r/ O(?<b> )OO /,
      ~r/ OO(?<b> )O /,
      ~r/  OO(?<b> )  /,
      ~r/   (?<b> )O  /,
      ~r/ O(?<b> )   /
    ]

    find_a_place(runs, offense_patterns, defense_patterns)
  end

  def find_a_place(%Gomoku.Runs{} = runs, :white = _my_color) do
    offense_patterns = [
      ~r/(?<b> )OOOO/,
      ~r/OOOO(?<b> )/,
      ~r/ (?<b> )OOO /,
      ~r/ OOO(?<b> ) /,
      ~r/ O(?<b> )OO /,
      ~r/ OO(?<b> )O /,
      ~r/  OO(?<b> )  /,
      ~r/   (?<b> )O  /,
      ~r/ O(?<b> )   /
    ]

    defense_patterns = [
      ~r/(?<b> )XXXX/,
      ~r/XXXX(?<b> )/,
      ~r/ (?<b> )XXX /,
      ~r/ XXX(?<b> ) /,
      ~r/ X(?<b> )XX /,
      ~r/ XX(?<b> )X /,
      ~r/  XX(?<b> )  /,
      ~r/   (?<b> )X  /,
      ~r/ X(?<b> )   /
    ]

    find_a_place(runs, offense_patterns, defense_patterns)
  end

  def find_a_place(%Gomoku.Runs{} = _runs, _my_color) do
    # Default case if no color is provided
    # You can handle this case as needed
    IO.puts("No color provided. Cannot determine a place.")
    raise "No color provided"
  end
end
