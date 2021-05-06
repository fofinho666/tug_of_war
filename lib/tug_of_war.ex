defmodule TugOfWar do
  @moduledoc """
  Documentation for `TugOfWar`.
  """
  defstruct [:team, :rival_team]

  @doc """
  Starts the game by setting your `team` the `rival_team` and the rope.
  """
  def set(team, rival_team, rope_length) do
    # making the integer division to be fair
    half_rope = div(rope_length, 2)

    team_rope = for n <- half_rope..1, do: n - 1
    TugOfWar.Team.set(team, team_rope)

    rival_team_rope = for n <- (half_rope + 1)..(half_rope * 2), do: n - 1
    TugOfWar.Team.set(rival_team, rival_team_rope)

    # Returns a %TugOfWar{} struct to be used
    %TugOfWar{team: team, rival_team: rival_team}
  end

  @doc """
  Pulls the rope by our team.
  """
  def pull(tug_of_war) do
    # Checks if we can pull the rival team. If so, add the pulled data to our team.
    # Otherwise, do nothing.
    case TugOfWar.Team.pulled(tug_of_war.rival_team) do
      :error -> :ok
      {:ok, rope_head} -> TugOfWar.Team.pull(tug_of_war.team, rope_head)
    end

    # Let's return the %TugOfWar{} itself
    tug_of_war
  end
end
