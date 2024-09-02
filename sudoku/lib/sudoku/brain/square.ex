defmodule Sudoku.Brain.Square do
  defstruct values: [], have_oned: false

  @moduledoc """
  logic for a single square
  new() - define square with all numbers
  new(n) - define square with just n
  remove(square, n) - remove n from square. raise "empty cell" if empty after removing
  is_just_one? - true if only one number in square
  have_just_oned - used to set flag
  have_just_oned? - test flag

  removing a number several times is not an error
  setting have_just_oned multiple time is an error
  """

  def new() do
    rv = %Sudoku.Brain.Square{}
    %{rv | values: [1, 2, 3, 4, 5, 6, 7, 8, 9]}
  end

  def new(n) when is_integer(n) and n >= 1 and n <= 9 do
    rv = %Sudoku.Brain.Square{}
    %{rv | values: [n]}
  end

  def remove(%Sudoku.Brain.Square{values: values} = s, n)
      when is_integer(n) and n >= 1 and n <= 9 do
    new_values = Enum.filter(values, fn v -> v != n end)

    if new_values == [] do
      raise "empty cell"
    end

    %{s | values: new_values}
  end

  def is_just_one?(%Sudoku.Brain.Square{values: values} = _s), do: length(values) == 1
end
