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

  def new(game_definition) when is_binary(game_definition) do
    g = Sudoku.Brain.Board.new()
    rows = condition_definition(game_definition)

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
    # Enum.map(all_coordinates(), fn coordinate -> {coordinate, Map.get(g, coordinate)} end)

    count =
      Enum.map(all_coordinates(), fn coordinate ->
        Map.get(g, coordinate) |> Sudoku.Brain.Square.count()
      end)
      |> Enum.filter(fn count_in_square -> count_in_square == 1 end)
      |> Enum.sum()

    %{board | known_count: count}
  end

  def row_for({vert, horz}), do: row_for(vert, horz)

  def row_for(vert, horz)
      when is_integer(vert) and is_integer(horz) and vert in 1..9 and horz in 1..9 do
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
    # coords_diagonal = for(v <- 1..9, do: {v, v})

    new_g =
      Enum.reduce(coords_lower, g, fn {v, h} = c, ng ->
        vl = Map.get(g, c)
        vu = Map.get(g, {h, v})
        Map.put(ng, c, vu) |> Map.put({h, v}, vl)
      end)

    # newer_g =
    #   Enum.reduce(coords_diagonal, new_g, fn c, ng ->
    #     vd = Map.get(g, c)
    #     Map.put(ng, c, vd)
    #   end)

    %{board | game: new_g}
  end

  def update_known(%Sudoku.Brain.Board{} = board) do
    update_places = get_update_places(board)

    Enum.reduce(update_places, board, fn coord, bd -> update_for_one_square(bd, coord) end)
    |> count_known_squares()
  end

  def to_string(%Sudoku.Brain.Board{} = board, form \\ :known) do
    s =
      Enum.reduce(all_coordinates(), "", fn coord, str ->
        str <> (at(board, coord) |> Sudoku.Brain.Square.to_string(form))
      end)

    # s |> dbg

    # s1 =
    Enum.map(0..80//9, fn start -> String.slice(s, start, 9) end)
    |> Enum.join("\n")

    # s1 |> dbg
  end

  def handle_one_and_onlies(%Sudoku.Brain.Board{} = board) do
    one_and_only_list = get_one_and_onlies(board)

    Enum.reduce(one_and_only_list, board, fn {coord, value}, board0 ->
      update_big_square(board0, value, coord)
    end)
  end

  defp get_one_and_onlies(%Sudoku.Brain.Board{} = board) do
    Enum.reduce(each_big_square(), board, fn coords, bd ->
      each_big_square_one_and_onlies(bd, coords)
    end)
  end

  defp each_big_square_one_and_onlies(%Sudoku.Brain.Board{} = board, coords)
       when is_list(coords) do
    value_counts =
      Enum.reduce(coords, %{}, fn coord, vc -> update_vc_map(vc, at(board, coord)) end)

    oao_values = Enum.filter(value_counts, fn {_v, c} -> c == 1 end)
    # need to return {coordinate, value} list when the square at coordinate
    # contains value and at least one more.
    # don't waste time if, e.g. every square is a big square is already known
    examine_list = for coord <- coords, val <- oao_values, do: {coord, val}

    process_list =
      Enum.filter(examine_list, fn {c, v} ->
        vals_at_c = vals_at(board, c)
        length(vals_at_c) > 1 and v in vals_at_c
      end)

    new_board = Enum.reduce(process_list, board, fn {c, v}, bd -> update_one_square(bd, v, c) end)
    new_board
  end

  defp update_vc_map(%{} = vc_map, %Sudoku.Brain.Square{values: values} = _values) do
    Enum.reduce(values, vc_map, fn val, vc ->
      c = Map.get(vc, val, 0)
      Map.put(vc, val, c + 1)
    end)
  end

  defp condition_definition(defn) when is_binary(defn) do
    String.split(defn, ["\r\n", "\n\r", "\r", "\n"])
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
    all_coordinates()
    |> Enum.filter(fn coordinate ->
      sq = at(board, coordinate)
      Sudoku.Brain.Square.is_just_one?(sq) and not Sudoku.Brain.Square.have_just_oned?(sq)
    end)
  end

  defp update_one_square(%Sudoku.Brain.Board{game: g} = board, value, {_v, _h} = coordinate) do
    square =
      at(board, coordinate)
      |> Sudoku.Brain.Square.remove(value)

    new_game = Map.put(g, coordinate, square)
    %{board | game: new_game}
  end

  defp set_oned(%Sudoku.Brain.Board{game: g} = board, {_v, _h} = coordinate) do
    square =
      at(board, coordinate)
      |> Sudoku.Brain.Square.have_just_oned()

    new_game = Map.put(g, coordinate, square)
    %{board | game: new_game}
  end

  defp all_coordinates() do
    for vert <- 1..9,
        horz <- 1..9,
        do: {vert, horz}
  end

  def each_big_square() do
    for vert <- 1..8//3,
        horz <- 1..8//3,
        do: big_square_for(vert, horz)
  end

  def at(%Sudoku.Brain.Board{game: g} = _bd, coordinate), do: Map.get(g, coordinate)

  def vals_at(%Sudoku.Brain.Board{} = bd, coordinate),
    do: at(bd, coordinate) |> Sudoku.Brain.Square.all_values()

  def count_at(%Sudoku.Brain.Board{} = bd, coordinate) do
    at(bd, coordinate) |> Sudoku.Brain.Square.count()
  end
end
