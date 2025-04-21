defmodule Gomoku.Play do
  def start(board_size, user_color) do
    # Initialize the game board
    board = Gomoku.Board.new(board_size, user_color)
    # Start the game loop
    game_loop(board)
  end

  def game_loop(board) do
    play_result =
      select_move(board)
      # Display the board only if user plays next
      |> Gomoku.Board.display()
      |> select_move()
      |> Gomoku.Board.display()
      |> Gomoku.Board.game_over?()

    case play_result do
      {:black_won, _board} -> IO.puts("Black wins!")
      {:white_won, _board} -> IO.puts("White wins!")
      {:draw, _board} -> IO.puts("It's a draw!")
      {:continue, board} -> game_loop(board)
    end
  end

  def select_move(%Gomoku.Board{} = board) do
    # Get the current player
    if board.human_player == board.current_player do
      ask_human_for_move(board)
    else
      # Make "Intelligent" move
      Gomoku.Intelligence.make_move(board)
    end
    |> Gomoku.Board.switch_player()
  end

  def ask_human_for_move(board) do
    # Prompt the user for a move
    IO.puts("Hello human! Enter your selection (e.g., aA or Aa): ")

    # Read the move from the user
    new_square = IO.gets("prompt?") |> String.trim()

    # Validate the move
    case Gomoku.Board.validate_selection(board, new_square) do
      :ok ->
        # Update the board with the move
        board = Gomoku.Board.update_board(board, new_square)
        {:continue, board}

      {:error, reason} ->
        IO.puts("Invalid selection: #{reason}")
        ask_human_for_move(board)
    end
  end
end
