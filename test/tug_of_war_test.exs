defmodule TugOfWarTest do
  use ExUnit.Case
  doctest TugOfWar

  test "greets the world" do
    assert TugOfWar.hello() == :world
  end
end
