defmodule SquareTest do
  use ExUnit.Case
  doctest Sudoku.Brain.Square

  test "can make a square" do
    s = Sudoku.Brain.Square.new()
    assert s != nil
  end

  test "can make a square from number" do
    s = Sudoku.Brain.Square.new(9)
    assert s != nil
  end

  test "is_just_one?" do
    s1 = Sudoku.Brain.Square.new(5)
    s9 = Sudoku.Brain.Square.new()

    assert Sudoku.Brain.Square.is_just_one?(s1) == true
    assert Sudoku.Brain.Square.is_just_one?(s9) == false
  end

  test "can remove number" do
    s9 = Sudoku.Brain.Square.new()
    s8 = Sudoku.Brain.Square.remove(s9, 9)
    assert Sudoku.Brain.Square.is_just_one?(s8) == false
    s1 = Enum.reduce([1, 2, 3, 4, 5, 6, 7], s8, fn v, s -> Sudoku.Brain.Square.remove(s, v) end)
    assert Sudoku.Brain.Square.is_just_one?(s1)

    try do
      Sudoku.Brain.Square.remove(s1, 8)
      flunk("removing last number didn't raise")
    catch
      :error, %RuntimeError{message: "empty cell"} -> :ok
    end
  end

  test "have or haven't just oned" do
    s1 = Sudoku.Brain.Square.new(5)
    assert Sudoku.Brain.Square.have_just_oned?(s1) == false
    s1j1 = Sudoku.Brain.Square.have_just_oned(s1)
    assert Sudoku.Brain.Square.have_just_oned?(s1j1) == true

    try do
      Sudoku.Brain.Square.have_just_oned(s1j1)
      flunk("succeeded in multiple have_just_oned")
    catch
      :error, %RuntimeError{message: "multiple have_just_oned calls"} -> :ok
    end

    s9 = Sudoku.Brain.Square.new()

    try do
      Sudoku.Brain.Square.have_just_oned(s9)
      flunk("succeeded in have_just_one-ing square with multiples")
    catch
      :error, %RuntimeError{message: "just_oned a non-unitary square"} -> :ok
    end
  end

  test "making a string" do
    s1 = Sudoku.Brain.Square.new(5)
    s9 = Sudoku.Brain.Square.new()

    ss1 = Sudoku.Brain.Square.to_string(s1)
    assert ss1 == "5"
    ss9 = Sudoku.Brain.Square.to_string(s9)
    assert ss9 == "123456789"
  end
end
