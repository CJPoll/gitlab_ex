defmodule GitlabExTest do
  use ExUnit.Case
  doctest GitlabEx

  test "greets the world" do
    assert GitlabEx.hello() == :world
  end
end
