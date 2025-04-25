defmodule Gomoku.Search do
  @moduledoc """
  This module provides functions for implementing the SEARCHES analysis.
  It also provides the searches structure
  """
  defstruct pattern: ~r/./,
            value: 0,
            type: :offense

  def new(pattern, value, type, :black = _mycolor)
      when is_binary(pattern) and is_integer(value) and is_atom(type) do
    regular_expression =
      String.replace(pattern, "+", "X")
      |> String.replace("-", "O")
      |> Regex.compile!()

    # Create a new SEARCHES struct with the board's grid and size
    %__MODULE__{
      pattern: regular_expression,
      value: value,
      type: type
    }
  end

  def new(pattern, value, type, :white = _mycolor)
      when is_binary(pattern) and is_integer(value) and is_atom(type) do
    regular_expression =
      String.replace(pattern, "+", "O")
      |> String.replace("-", "X")
      |> Regex.compile!()

    # Create a new SEARCHES struct with the board's grid and size
    %__MODULE__{
      pattern: regular_expression,
      value: value,
      type: type
    }
  end
end
