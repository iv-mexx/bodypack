defmodule BodyPackTest do
  use ExUnit.Case
  doctest BodyPack

  test "greets the world" do
    assert BodyPack.hello() == :world
  end
end
