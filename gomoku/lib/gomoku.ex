defmodule Gomoku do
  @moduledoc """
  Documentation for `Gomoku`.
  """

  @board_tiny 7
  @board_small 9
  @board_default 15
  @board_large 19
  @color_default :black
  @color_white :white
  @color_black :black

  def main(argv \\ []) do
    # Parse command-line arguments

    {board_size, user_color} = parse_args(argv)
    IO.puts("Board size: #{board_size}")
    IO.puts("User color: #{user_color}")
    Gomoku.Play.start(board_size, user_color)
  end

  defp parse_args(args) do
    {option_list, extras} = OptionParser.parse!(args, switches: [board: :string, color: :string])
    option_list = option_list ++ extras

    size_fn = fn arg, size ->
      case arg do
        "tiny" -> @board_tiny
        "small" -> @board_small
        "default" -> @board_default
        "medium" -> @board_default
        "large" -> @board_large
        {:board, "tiny"} -> @board_tiny
        {:board, "small"} -> @board_small
        {:board, "medium"} -> @board_default
        {:board, "default"} -> @board_default
        {:board, "large"} -> @board_large
        _ -> size
      end
    end

    color_fn = fn arg, color ->
      case arg do
        "black" -> @color_black
        {:black, true} -> @color_black
        {:white, true} -> @color_white
        "white" -> @color_white
        _ -> color
      end
    end

    board_size = Enum.reduce(option_list, @board_tiny, size_fn)
    user_color = Enum.reduce(option_list, @color_default, color_fn)
    {board_size, user_color}
  end
end
