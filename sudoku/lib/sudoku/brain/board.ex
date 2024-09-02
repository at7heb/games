defmodule Sudoku.Brain.Board do
  defstruct game: %{}, known_count: 81

  # def new()
  # def new(init) when is_binary(init)
  # def row_for(vert, horz) when is_integer(vert) and is_integer(horz)
  # def square_for(vert, horz) when is_integer(vert) and is_integer(horz)
  # def transpose(%Sudoku_Game{} = g)
  # def update_known(%Sudoku_Game{} = g)

  def new() do
    for vert <- 1..9,
        horz <- 1..9,
        do:
          {vert, horz}
          |> Enum.reduce(%{}, fn coordinates, g ->
            Map.put(g, coordinates, 1..9 |> Enum.to_list())
          end)
  end

  # def new(init) when is_binary(init) do
  #   g = Sudoku.Brain.Board.new()
  #   i1 = String.split(init)
  # end
end
