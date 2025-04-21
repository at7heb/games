defmodule Gomoku.Board do
  @horizontal ~w/A B C D E F G H I J K L M N O P Q R S/
  @vertical ~w/a b c d e f g h i j k l m n o p q r s/

  # states: :playing, :black_won, :white_won, :draw
  defstruct h_list: [],
            v_list: [],
            size: 0,
            grid: %{},
            current_player: :black,
            human_player: :black,
            state: :playing

  def new(size, human_color) do
    # Create a new board with the given size

    %__MODULE__{
      h_list: Enum.take(@horizontal, size),
      v_list: Enum.take(@vertical, size),
      size: size,
      grid: %{},
      current_player: :black,
      human_player: human_color,
      state: :playing
    }
  end

  def canonicalize(coord) when is_binary(coord) do
    coord
    |> String.trim()
    |> String.split("", trim: true)
    |> Enum.sort(fn a, b -> a < b end)
    |> Enum.join()
  end

  def validate_selection(%__MODULE__{} = board, new_square) do
    # Validate the move
    new_square = canonicalize(new_square)

    if String.length(new_square) != 2 do
      {:error, "Invalid selection1"}
    else
      [h, v] = String.split(new_square, "", trim: true)

      if h in board.h_list and v in board.v_list do
        if Map.has_key?(board.grid, new_square) do
          {:error, "Square already occupied"}
        else
          :ok
        end
      else
        {:error, "Invalid selection2"}
      end
    end
  end

  def update_board(%__MODULE__{} = board, new_square) do
    new_square = canonicalize(new_square)
    color = board.current_player

    # Update the board with the new move
    grid = Map.put(board.grid, new_square, color)

    # Check for win condition
    state = check_win_condition(grid, new_square, color)

    %__MODULE__{
      board
      | grid: grid,
        current_player: if(color == :black, do: :white, else: :black),
        state: state
    }
  end

  def check_win_condition(grid, _new_square, color) do
    # Check for win condition
    # This is a placeholder implementation
    # Replace with actual logic to check for a win
    if map_size(grid) >= 5 do
      if color == :black do
        :black_won
      else
        :white_won
      end
    else
      :playing
    end
  end

  def display(%__MODULE__{} = board) do
    # Display the board
    IO.puts("Current Player: #{board.current_player}")
    IO.puts("Board Size: #{board.size}")
    IO.puts("Grid: #{inspect(board.grid)}")
    IO.puts("State: #{board.state}")
    boundary = String.duplicate("-", board.size + 2)

    # Display the grid
    IO.puts(boundary)

    for row <- 0..(board.size - 1) do
      for col <- 0..(board.size - 1) do
        square = "#{Enum.at(board.h_list, col)}#{Enum.at(board.v_list, row)}"
        color = Map.get(board.grid, square, :empty)

        output_color =
          case color do
            # Black
            :black -> "X"
            # White
            :white -> "O"
            # Reset
            :empty -> " "
          end

        {left_annotation, right_annotation} =
          cond do
            col == 0 -> {"|", ""}
            col == board.size - 1 -> {"", "|\n"}
            true -> {"", ""}
          end

        IO.write("#{left_annotation}#{output_color}#{right_annotation}")
      end
    end

    IO.puts(boundary)

    board
  end

  def game_over?(%__MODULE__{} = board) do
    case board.state do
      :black_won -> {:black_won, board}
      :white_won -> {:white_won, board}
      :draw -> {:draw, board}
      _ -> {:continue, board}
    end
  end

  def switch_player({:continue, %__MODULE__{} = board}), do: switch_player(board)

  def switch_player({condition, %__MODULE__{} = board}) do
    # only switch player if no exception
    IO.puts("*Not* switching player when condition is #{condition}")
    board
  end

  def switch_player(%__MODULE__{} = board) do
    # Switch the current player
    new_player = if board.current_player == :black, do: :white, else: :black
    IO.puts("Switching player from #{board.current_player} to #{new_player}")

    %__MODULE__{
      board
      | current_player: new_player
    }
  end
end
