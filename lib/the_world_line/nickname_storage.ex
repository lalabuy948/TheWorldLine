defmodule TheWorldLine.NicknameStorage do
  use Agent

  def start_link(_args) do
    Agent.start_link(fn -> MapSet.new() end, name: __MODULE__)
  end

  def list do
    Agent.get(__MODULE__, & &1)
  end

  def add(element) do
    Agent.update(__MODULE__, &MapSet.put(&1, element))
  end

  def delete(element) do
    Agent.update(__MODULE__, &MapSet.delete(&1, element))
  end

  def exists?(element) do
    Agent.get(__MODULE__, &MapSet.member?(&1, element))
  end
end
