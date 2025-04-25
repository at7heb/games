defmodule Gomoku.Intelligence do
  alias Gomoku.Search

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
  def find_a_place(%Gomoku.Runs{} = runs, my_color) when is_atom(my_color) do
    find_a_place(runs, patterns(my_color))
  end

  def find_a_place(%Gomoku.Runs{} = runs, patterns) when is_list(patterns) do
    # Default case if no color is provided
    # You can handle this case as needed
    IO.puts("No color provided. Cannot determine a place.")
    raise "No color provided"
  end

  def find_a_place(%Gomoku.Runs{} = runs, offense_patterns, defense_patterns) do
    # Find a place based on the provided patterns
    # This is a placeholder implementation
    # Replace with actual logic to determine the move

    # Check offense patterns
    # Check defense patterns
    Enum.find_value(offense_patterns, fn pattern ->
      case Regex.run(pattern, runs.h_runs) do
        nil -> nil
        [_, place] -> place
      end
    end) ||
      Enum.find_value(defense_patterns, fn pattern ->
        case Regex.run(pattern, runs.h_runs) do
          nil -> nil
          [_, place] -> place
        end
      end)
  end

  def patterns(my_color) do
    [
      Search.new("(?<b> )MMMM", 100, :offense, my_color),
      Search.new("MMMM(?<b> )", 100, :offense, my_color),
      Search.new(" (?<b> )MMM ", 100, :offense, my_color),
      Search.new(" MMM(?<b> ) ", 100, :offense, my_color),
      Search.new("   (?<b> )    ", 70, :defense, my_color),
      Search.new("  (?<b>M)    ", 65, :defense, my_color),
      Search.new("   (?<b>M)    ", 65, :defense, my_color),
      #   ~r/ XXX(?<b> ) /,
      # all may be lost; don't bring attention
      Search.new("(?<b> )OOOO", 0, :defense, my_color),
      Search.new("OOOO(?<b> )", 0, :defense, my_color),
      Search.new("(?<b> )OOO", 98, :defense, my_color),
      Search.new("OOO(?<b> )", 98, :defense, my_color)
    ]

    # offense_patterns = [
    #   ~r/(?<b> )XXXX/,
    #   ~r/XXXX(?<b> )/,
    #   ~r/ (?<b> )XXX /,
    #   ~r/ XXX(?<b> ) /,
    #   ~r/ X(?<b> )XX /,
    #   ~r/ XX(?<b> )X /,
    #   ~r/  XX(?<b> )  /,
    #   ~r/   (?<b> )X  /,
    #   ~r/ X(?<b> )   /
    # ]

    # defense_patterns = [
    #   ~r/(?<b> )OOOO/,
    #   ~r/OOOO(?<b> )/,
    #   ~r/ (?<b> )OOO /,
    #   ~r/ OOO(?<b> ) /,
    #   ~r/ O(?<b> )OO /,
    #   ~r/ OO(?<b> )O /,
    #   ~r/  OO(?<b> )  /,
    #   ~r/   (?<b> )O  /,
    #   ~r/ O(?<b> )   /
    # ]
  end
end
