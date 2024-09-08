defmodule Sudoku.Brain.Play do
  def playit(path_to_game_file) when is_binary(path_to_game_file) do
    defn = File.read!(path_to_game_file)
    play(defn)
  end

  def play(game_definition) when is_binary(game_definition) do
    Sudoku.Brain.Board.new(game_definition)
    |> game_plays()
  end

  def game_plays(%Sudoku.Brain.Board{} = board) do
    initial_count = Sudoku.Brain.Board.known_count(board)

    new_board = Sudoku.Brain.Board.update_known(board)

    new2_board = Sudoku.Brain.Board.handle_one_and_onlies(new_board)
    new3_board = Sudoku.Brain.Board.update_known(new2_board)

    new4_board = Sudoku.Brain.Board.handle_2or3_and_onlies(new3_board)
    new5_board = Sudoku.Brain.Board.update_known(new4_board)
    next_count = Sudoku.Brain.Board.known_count(new5_board)

    if initial_count == next_count do
      new3_board
    else
      game_plays(new3_board)
    end
  end
end
