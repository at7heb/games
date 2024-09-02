defmodule Sudoku.Brain.Board do
  defstruct game: %{}, known_count: 0

  # def new()
  # def new(init) when is_binary(init)
  # def row_for(vert, horz) when is_integer(vert) and is_integer(horz)
  # def square_for(vert, horz) when is_integer(vert) and is_integer(horz)
  # def transpose(%Sudoku_Game{} = g)
  # def update_known(%Sudoku_Game{} = g)

  def new() do
    coordinates =
      for vert <- 1..9,
          horz <- 1..9,
          do: {vert, horz}

    game =
      Enum.reduce(coordinates, %{}, fn coordinates, g ->
        Map.put(g, coordinates, Sudoku.Brain.Square.new())
      end)

    board = %Sudoku.Brain.Board{}
    %{board | game: game}
  end

  def new(init) when is_binary(init) do
    g = Sudoku.Brain.Board.new()
    rows = String.split(init, "\n")

    new(g, rows, 1)
    |> count_known_squares()
  end

  def new(%Sudoku.Brain.Board{} = board, [], _), do: board

  def new(%Sudoku.Brain.Board{} = board, [row | rest], vert_index),
    # {vert_index, row, rest} |> dbg
    do:
      new(board, row, vert_index, 1)
      |> new(rest, vert_index + 1)

  def new(%Sudoku.Brain.Board{} = board, row, vert_index, horz_index)
      when is_binary(row) and row != "" do
    coordinate = {vert_index, horz_index}
    content = String.first(row)

    cond do
      content == " " ->
        board

      true ->
        new_square = Sudoku.Brain.Square.new(String.to_integer(content))
        # {coordinate, content, new_square} |> dbg
        new_game = Map.put(board.game, coordinate, new_square)

        %{board | game: new_game}
    end
    |> new(String.slice(row, 1..9), vert_index, horz_index + 1)
  end

  def new(%Sudoku.Brain.Board{} = board, _row, _vert_index, _horz_index),
    do: board

  def known_count(%Sudoku.Brain.Board{known_count: count} = _b), do: count

  def count_known_squares(%Sudoku.Brain.Board{game: g} = board) do
    coordinates = for vert <- 1..9, horz <- 1..9, do: {vert, horz}

    Enum.map(coordinates, fn coordinate -> {coordinate, Map.get(g, coordinate)} end)

    count =
      Enum.map(coordinates, fn coordinate ->
        Map.get(g, coordinate) |> Sudoku.Brain.Square.count()
      end)
      |> Enum.filter(fn count_in_square -> count_in_square == 1 end)
      |> Enum.sum()

    %{board | known_count: count}
  end

  def row_for(vert, horz) when is_integer(vert) and is_integer(horz) and vert in 1..9 do
    for(column <- 1..9, do: {vert, column})
    |> Enum.filter(fn coordinate -> coordinate != {vert, horz} end)
  end

  def square_for(vert, horz) when is_integer(vert) and is_integer(horz) do
    vert0 = 3 * div(vert - 1, 3) + 1
    horz0 = 3 * div(horz - 1, 3) + 1

    for(
      row <- vert0..(vert0 + 2),
      column <- horz0..(horz0 + 2),
      do: {row, column}
    )
    |> Enum.filter(fn coordinate -> coordinate != {vert, horz} end)
  end
end
