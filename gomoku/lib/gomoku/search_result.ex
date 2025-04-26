defmodule Gomoku.SearchResult do
  defstruct [:type, :value, :coordinate, :direction, :move_location]

  @type search_result :: %__MODULE__{
          type: :offense | :defense,
          value: integer(),
          coordinate: String.t(),
          direction: :r000 | :r090 | :r045 | :r135,
          move_location: {integer(), integer()}
        }

  # Gomoku.SearchResult.new(:direction, coordinate, search.type, search.value, move_location)

  def new(direction, coordinate, search_type, search_value, move_location) do
    %__MODULE__{
      type: search_type,
      value: search_value,
      coordinate: coordinate,
      direction: direction,
      move_location: move_location
    }
  end

  def best_search_result(search_results) when is_list(search_results) do
    search_results =
      Enum.sort(search_results, fn %__MODULE__{value: a_search_value} = _a,
                                   %__MODULE__{value: b_search_value} = _b ->
        a_search_value >= b_search_value
      end)

    cond do
      search_results == [] ->
        :none

      true ->
        max_value_result = Enum.max_by(search_results, & &1.value)

        chosen_result =
          Enum.filter(search_results, fn %__MODULE__{value: value} ->
            value == max_value_result.value
          end)
          |> Enum.shuffle()
          |> Enum.take(1)

        {:move, chosen_result}
    end
  end
end
