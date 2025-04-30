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
    # |> dbg
    place = find_a_place(runs, board.current_player)

    place_coordinates =
      case place do
        :none ->
          # really use board to make a random move.
          random_place = Gomoku.Board.random_place(board)
          IO.puts("Random move: #{random_place} by player #{board.current_player}")
          random_place

        # here we cae about
        # coordinate: coordinate,
        # direction: direction,
        # move_location: move_location

        {:move, chosen_result} ->
          Gomoku.Board.coordinate_from_search_result(
            board,
            chosen_result.coordinate,
            chosen_result.direction,
            chosen_result.move_location
          )
      end

    # IO.puts("Intelligent move: #{place} by player #{board.current_player}")
    # place_coordinates |> dbg()

    new_board =
      Gomoku.Board.validate_selection(board, place_coordinates)
      |> case do
        :ok ->
          # Update the board with the move
          IO.puts("Intelligent move to: #{place_coordinates} by player #{board.current_player}")
          Gomoku.Board.update_board(board, place_coordinates)

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
    scan_sequence = fn {direction, coordinate, row}, %Gomoku.Search{} = search ->
      Regex.scan(search.pattern, row, return: :index)
      |> Enum.map(fn [_whole, {_s, _l} = move_location] ->
        Gomoku.SearchResult.new(direction, coordinate, search.type, search.value, move_location)
      end)
    end

    for run <- [
          runs.h_runs,
          runs.v_runs,
          runs.dr_runs_u,
          runs.dr_runs_l,
          runs.ur_runs_u,
          runs.ur_runs_l
        ],
        sequence <- run,
        pattern <- patterns do
      # {run, sequence, pattern}
      scan_result = scan_sequence.(sequence, pattern)
      # {sequence, pattern, scan_result} |> dbg()
      scan_result
    end
    |> Gomoku.SearchResult.best_search_result()
  end

  def patterns(my_color) do
    [
      Search.new("(?<b> )++++", 100, :offense, my_color),
      Search.new("-(?<b> )    ", 5, :defense, my_color),
      Search.new("   (?<b> )-", 5, :defense, my_color),
      Search.new("++++(?<b> )", 100, :offense, my_color),
      Search.new(" (?<b> )+++ ", 100, :offense, my_color),
      Search.new(" +++(?<b> ) ", 100, :offense, my_color),
      Search.new("   (?<b> )    ", 70, :defense, my_color),
      Search.new("  (?<b> )-    ", 65, :defense, my_color),
      Search.new("   -(?<b> )    ", 65, :defense, my_color),
      #   ~r/ XXX(?<b> ) /,
      # all may be lost; don't bring attention
      Search.new("(?<b> )----", 0, :defense, my_color),
      Search.new("----(?<b> )", 0, :defense, my_color),
      Search.new("(?<b> )---", 98, :defense, my_color),
      Search.new("---(?<b> )", 98, :defense, my_color)
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
