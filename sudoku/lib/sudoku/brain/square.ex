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
  to_string - remaining numbers, no spaces

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

  def have_just_oned(%Sudoku.Brain.Square{have_oned: true}),
    do: raise("multiple have_just_oned calls")

  def have_just_oned(%Sudoku.Brain.Square{values: values} = s) do
    if length(values) != 1 do
      raise "just_oned a non-unitary square"
    end

    %{s | have_oned: true}
  end

  def have_just_oned?(%Sudoku.Brain.Square{have_oned: v}), do: v

  def to_string(%Sudoku.Brain.Square{values: values}, form \\ :full) do
    digits = " ①②③④⑤⑥⑦⑧⑨"
    unknowns = "  abcdefgh"

    case form do
      :full ->
        values
        |> Enum.map(fn v -> Integer.to_string(v) end)
        |> Enum.join()

      :short ->
        if length(values) == 1 do
          String.slice(digits, hd(values), 1)
        else
          String.slice(unknowns, length(values), 1)
        end

      :known ->
        if length(values) == 1 do
          String.slice(digits, hd(values), 1)
        else
          "_"
        end
    end
  end

  def count(%Sudoku.Brain.Square{values: values}), do: length(values)

  def value(%Sudoku.Brain.Square{values: values}) do
    case length(values) do
      0 -> raise "value of empty cell"
      1 -> hd(values)
      _ -> raise "value of multi-cell"
    end
  end

  def all_values(%Sudoku.Brain.Square{values: values}), do: values
end
