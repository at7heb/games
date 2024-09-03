defmodule Sudoku.Brain.Board do
  defstruct game: %{}, known_count: 0

  # def update_known(%Sudoku_Game{} = g)

  def new() do
    coordinates = all_coordinates()

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

  defp count_known_squares(%Sudoku.Brain.Board{game: g} = board) do
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

  def row_for({vert, horz}), do: row_for(vert, horz)

  def row_for(vert, horz) when is_integer(vert) and is_integer(horz) and vert in 1..9 do
    for(column <- 1..9, do: {vert, column})
    |> Enum.filter(fn coordinate -> coordinate != {vert, horz} end)
  end

  def big_square_for({vert, horz}), do: big_square_for(vert, horz)

  def big_square_for(vert, horz) when is_integer(vert) and is_integer(horz) do
    vert0 = 3 * div(vert - 1, 3) + 1
    horz0 = 3 * div(horz - 1, 3) + 1

    for(
      row <- vert0..(vert0 + 2),
      column <- horz0..(horz0 + 2),
      do: {row, column}
    )
    |> Enum.filter(fn coordinate -> coordinate != {vert, horz} end)
  end

  def transpose(%Sudoku.Brain.Board{game: g} = board) do
    coords_lower = for(v <- 2..9, h <- 1..(v - 1), do: {v, h})
    coords_diagonal = for(v <- 1..9, do: {v, v})

    new_g =
      Enum.reduce(coords_lower, %{}, fn {v, h} = c, ng ->
        vl = Map.get(g, c)
        vu = Map.get(g, {h, v})
        Map.put(ng, c, vu) |> Map.put({h, v}, vl)
      end)

    newer_g =
      Enum.reduce(coords_diagonal, new_g, fn c, ng ->
        vd = Map.get(g, c)
        Map.put(ng, c, vd)
      end)

    %{board | game: newer_g}
  end

  def update_known(%Sudoku.Brain.Board{} = board) do
    update_places = get_update_places(board)

    Enum.reduce(update_places, board, fn coord, bd -> update_for_one_square(bd, coord) end)
  end

  defp update_for_one_square(%Sudoku.Brain.Board{} = board, {v, h} = coordinate) do
    value = at(board, coordinate) |> Sudoku.Brain.Square.value()

    update_big_square(board, value, coordinate)
    |> update_row(value, coordinate)
    |> transpose()
    |> update_row(value, {h, v})
    |> transpose()
    |> set_oned(coordinate)
  end

  defp update_big_square(%Sudoku.Brain.Board{} = board, value, {_v, _h} = coordinate) do
    big_square_for(coordinate)
    |> Enum.reduce(board, fn coord, bd -> update_one_square(bd, value, coord) end)
  end

  defp update_row(%Sudoku.Brain.Board{} = board, value, {_v, _h} = coordinate) do
    row_for(coordinate)
    |> Enum.reduce(board, fn coord, bd -> update_one_square(bd, value, coord) end)
  end

  defp get_update_places(%Sudoku.Brain.Board{} = board) do
    at(board, {1, 9}) |> dbg

    all_coordinates()
    |> Enum.filter(fn coordinate ->
      sq = at(board, coordinate)
      Sudoku.Brain.Square.is_just_one?(sq) and not Sudoku.Brain.Square.have_just_oned?(sq)
    end)
    |> dbg
  end

  defp update_one_square(%Sudoku.Brain.Board{game: g} = board, value, {_v, _h} = coordinate) do
    square =
      at(board, coordinate)
      |> Sudoku.Brain.Square.remove(value)

    {coordinate, value, square} |> dbg
    new_game = Map.put(g, coordinate, square)
    %{board | game: new_game}
  end

  defp set_oned(%Sudoku.Brain.Board{game: g} = board, {_v, _h} = coordinate) do
    square =
      at(board, coordinate)
      |> Sudoku.Brain.Square.have_just_oned()

    {"board set oned", coordinate, square} |> dbg

    new_game = Map.put(g, coordinate, square)
    %{board | game: new_game}
  end

  defp all_coordinates() do
    for vert <- 1..9,
        horz <- 1..9,
        do: {vert, horz}
  end

  def at(%Sudoku.Brain.Board{game: g} = _bd, coordinate), do: Map.get(g, coordinate)

  def count_at(%Sudoku.Brain.Board{game: g} = _bd, coordinate) do
    Map.get(g, coordinate) |> Sudoku.Brain.Square.count()
  end
end
