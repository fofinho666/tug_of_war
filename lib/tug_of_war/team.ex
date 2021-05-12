defmodule TugOfWar.Team do
  use Agent

  @doc """
  Starts a team with the given `name`.

  The team name is given so we can identify
  the team by name instead of using a PID.
  """
  def start_link(name) do
    Agent.start_link(fn -> [] end, name: name)
  end

  @doc """
  Get the amount of rope that the team have ther possession.
  """
  def get(team) do
    Agent.get(team, fn team_rope -> team_rope end)
  end

  @doc """
  Sets the amount of rope that the team have.
  """
  def set(team, rope) do
    Agent.update(team, fn _ -> rope end)
  end

  @doc """
  Pulls a `value` into the team's rope.
  """
  def pull(team, value) do
    Agent.update(team, fn team_rope -> [value | team_rope] end)
  end

  @doc """
  Remove an element from the `team`.

  Returns `{:ok, rope_head}` if there is a value on the rope's head to give away
  or `:error` if the rope is currently empty.
  """
  def pulled(team) do
    Agent.get_and_update(team, fn
      [] -> {:error, []}
      [rope_head | rope_tail] -> {{:ok, rope_head}, rope_tail}
    end)
  end
end
