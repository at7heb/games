defmodule Sudoku.Brain.Play do
  def playit(path_to_game_file) when is_binary(path_to_game_file) do
    defn = File.read!(path_to_game_file)
    play(defn)
  end

  def play(game_definition) when is_binary(game_definition) do
    Sudoku.Brain.Board.new(game_definition)
    |> game_plays()
  end

  def play(%Sudoku.Brain.Board{} = board), do: game_plays(board)

  def game_plays(%Sudoku.Brain.Board{} = board) do
    initial_count = Sudoku.Brain.Board.values_count(board)

    new_board =
      Sudoku.Brain.Board.update_known(board)
      |> Sudoku.Brain.Board.handle_one_and_onlies()
      |> Sudoku.Brain.Board.update_known()
      |> Sudoku.Brain.Board.handle_2or3_and_onlies()
      |> Sudoku.Brain.Board.update_known()
      |> Sudoku.Brain.Board.handle_one_and_onlies()
      |> Sudoku.Brain.Board.update_known()
      |> Sudoku.Brain.Board.handle_2or3_and_onlies()
      |> Sudoku.Brain.Board.update_known()

    next_count = Sudoku.Brain.Board.values_count(new_board)
    {initial_count, next_count} |> dbg

    if initial_count == next_count do
      new_board
    else
      game_plays(new_board)
    end
  end
end
