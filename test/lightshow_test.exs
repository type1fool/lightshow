defmodule LightshowTest do
  use ExUnit.Case
  doctest Lightshow

  test "greets the world" do
    assert Lightshow.hello() == :world
  end
end
