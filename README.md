# TugOfWar

The goal of this project is to get a first contact with Elixir what this amazing programing language brings out of the box by using the Erlang virtual machine.

We'll start by covering some basics of the language and by the end, we'll be fighting for a list of numbers with someone else on our local network.

May the strong IEx wins!
## Table of content
- [Instalation](#instalation)
- [IEx and basic data types](#iex-and-basic-data-types)
- [Pattern matching](#pattern-matching)
- [Functions and the pipe operator](#functions-and-the-pipe-operator)
- [Let's create our project](#lets-create-our-project)
- [Abstracting Teams as Agents](#abstracting-teams-as-agents)
- [Preparing the match](#preparing-the-match)

## Instalation
To get started we need to install Elixir. You can follow the official guide to so [here](https://elixir-lang.org/install.html).

If you are going to play with someone else, be sure to use the **same** Elixir version. You use something like [asdf](https://asdf-vm.com/#/) to manage your Elixir versions

If everything went well you can run this command to see the version you have installed:
```bash
$ elixir -v

Erlang/OTP 23 [erts-11.1.8] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe] [dtrace]

Elixir 1.11.4 (compiled with Erlang/OTP 23)
```
## IEx and basic data types

Elixir's best friend is IEx, the language shell or REPL if you want to call it. Here you can write your code and it will be evaluated in real time.

Let's start the IEx by typing `$ iex` on our terminal and play a bit:

```elixir
iex>x = 2 + 2
4
iex> x - 1
3
iex> "quick" <> "maths"
"quickmaths"
iex> # I forgot a space"
nil
```

We also commonly use other data types:
```elixir
iex> :atom           # An atom (known as Identifier/Symbols in other languages)
:atom
iex> [1, 2, "three"] # Lists (typically hold a dynamic amount of items)
[1, 2, "three"]
iex> {:ok, "value"}  # Tuples (typically hold a fixed amount of items)
{:ok, "value"}
```

At the end of the project, we'll be fighting for a list of numbers on iex, something like:

```elixir
iex> team = TugOfWar.ready(:benfica)
{:benfica, :our_name@our_host}
iex> rival_team = {:sporting, :their_name@their_host}
{:sporting, :their_name@their_host}
tug = TugOfWar.set(team, rival_team, 4)
#TugOfWar<
  US {:benfica, :our_name@our_host} vs THEM {:sporting, :their_name@their_host}
                             [0, 1] >< [2, 3]
>
iex> TugOfWar.pull(tug)
#TugOfWar<
  US {:benfica, :our_name@our_host} vs THEM {:sporting, :their_name@their_host}
                          [0, 1, 2] >< [3]
>
```
## Pattern matching

The `=` operator is not what you think on Elixir. Let's open a shell and try it out:
```elixir
iex> y = 9
9
iex> y
9
iex> 9 = y
9
```
What?? How did the last operation work? This is because the `=` is the match operator, not the assignment operator as in other languages. It tries to match the right side (y with value 9) against the left side (the number 9).
```elixir
iex> 8 = y
** (MatchError) no match of right hand side value: 9
```
Like so, if the sides don't match we got an error.

We can also pattern match data structures. Take the example of lists, by matching with `[head|tail]` we can extract the first element or the Head and the rest of the elements or the Tail.

```elixir
iex> [head|tail] = [1,2,3,4]
[1, 2, 3, 4]
iex> head
1
iex> tail
[2, 3, 4]
```

If we match `[head|tail]` with and empty list, an error is thrown
```elixir
iex> [head|tail] = []
** (MatchError) no match of right hand side value: []
```

We also can use this`[head|tail]` expression to add values to an list by add a new Head

```elixir
iex> list = [3,2,1]
[3, 2, 1]
iex> [4|list]
[4, 3, 2, 1]
```

## Functions and the pipe operator

I lied to you. The truth is that all data structures in Elixir are immutable.
So in the last example were not adding to the list but instead creating a new list with a new head.

For me, there are 2 "Everything"s on this programing language.

1. "Everything" is immutable
2. "Everything" is a function

Could we make a function to add elements to a list? Yes we can:
```elixir
iex> list = [1,2,3]
[1, 2, 3]
iex> new_head = fn list, head -> [head|list] end
#Function<43.79398840/2 in :erl_eval.expr/5>
iex> new_head.(list, 0)
[0, 1, 2, 3]
```
What's going on? First, we assiged an anonymous function to `new_head` variable so that we can invoke it later.

The anonymous function is defined by the `fn` and `end` words, the arrow `->` separates the function arguments from its body.

This function does the same as the previous example, it creates a new list with a new head element, but where's the return of the function? Well, the last statement of a function is always its return.

What if I want to add another head by resusing the same function? There is two ways to do it:

```elixir
iex> new_head.(new_head.(new_head.([],1),2),3)
[3, 2, 1]
iex> [] |> new_head.(1) |> new_head.(2) |> new_head.(3)
[3, 2, 1]
```

Which one do you prefer? I guess the second where we use that `|>` thing. Please meet the Pipe operator.

It takes what is on its left side and injects it as the first parameter of the function that is on its right, making things more readable

## Let's create our project

To create our project we'll use `mix`, a build tool that elixir ships with and, it allows us to create, test, and compile projects. Let's create our project:

`$ mix new tug_of_war --sup`

This command will create our project named `tug_of_war` in a folder with the same name. The `--sup` flag tells mix to create a project with a supervision tree that will talk about it later on.

Let's go to the project folder and see what is inside

- `_build` - a folder that contains compilation artifacts
- `lib` - the folder that will have our code
- `test` - a folder where we can define our tests
- `.formatter.exs` - The default settings of the build-in code formatter that we can run with `$ mix format`.
- `mix.exs` - the file where we configure everything about the project like name, dependencies, and other things

For now on we'll start our project with a shell session. To do it we'll tell iex to use our mix.exs like so:

`$ iex -S mix`

## Abstracting Teams as Agents

Since everything is imutable me need something to keep the state of how much rope the team have. We can use Agents as an abstraction since it holds a state of a process for us.

Let's try to create an agent:

```bash
iex> {:ok, agent} = Agent.start_link(fn -> "our state" end)
{:ok, #PID<0.110.0>}
iex>  Agent.get(agent, fn list -> list end)
"our state"
iex> Agent.update(agent, fn state -> "#{state} updated" end)
:ok
iex> Agent.get(agent, fn state -> state end)
"our state updated"
```

As we can see, we've created an Agent by passing a function that returned the string `"our state"` as state.

The Agent created returned `{:ok, #PID<0.110.0>}`, a tuple "thats why the curly brackes" with an atom `:ok` and a process identifier (PID).

Atoms in Elixir are used as tags, in this case we are tagging that the agent creations as successfully.

The `#PID<...>` that we saved on the agent variable, is the process identifier of the agent. The agent is a Elixir process which is isolated and very lightweight in terms of memory and CPU.

As we can see, we've updated and requested the agent's state using its PID. Processes in Elixir only interact with the outside through messages, so basically what happened was that we just send a message to that process to get or update the status

Let's create a Team using an Agent by creating a file at `lib/tug_of_war/team.ex` with the foloowing:

```elixir
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
  Remove an element from the `rope`.

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
```
In Elixir we group several functions into modules. Here we defined  five documented functions to interact with our Agent process. We also add to the top of the module `use Agent`, this in the future allow us to supervise our agent.

This `use` macro
injects any code in the current module, such as importing itself or other modules, defining new functions, setting a module state, etc.

Let's practice with our team by opening a shell again:

```elixir
iex> TugOfWar.Team.start_link(:benfica)
{:ok, #PID<0.143.0>}
iex> TugOfWar.Team.get(:benfica)
[]
iex> TugOfWar.Team.set(:benfica, [1])
:ok
iex> TugOfWar.Team.get(:benfica)
[1]
iex> TugOfWar.Team.pull(:benfica, 0)
:ok
iex> TugOfWar.Team.get(:benfica)
[0, 1]
iex> TugOfWar.Team.pulled(:benfica)
{:ok, 0}
iex> TugOfWar.Team.pulled(:benfica)
{:ok, 1}
iex> TugOfWar.Team.pulled(:benfica)
:error
iex> TugOfWar.Team.get(:benfica)
[]
```

Geat! We ready for a match! Meanwhile, if you forget how to play you can check out the documentation on the shell, like so:
```bash
iex> h TugOfWar.Team.start_link

                              def start_link(name)

Starts a team with the given name.

The team name is given so we can identify the team by name instead of using a
PID.

```
## Preparing the match

For our match we'll need to keep tack of the teams that are playing. We are going to create a struct called `TugOfWar`. But how we define a struct? Let's see:

```elixir
iex> defmodule Player do
...>    defstruct [:name, :number]
...> end
{:module, Player,
 <<...>>,
 %Player{name: nil, number: nil}}
iex> cr7 = %Player{name: "Cristiano Reinaldo", number: 7}
%Player{name: "Cristiano Reinaldo", number: 7}
iex> cr7.name
"Cristiano Reinaldo"
iex> %Player{number: number} = cr7
%Player{name: "Cristiano Reinaldo", number: 7}
iex(5)> number
7
```
A struct is only defined within a module and gets its name on the process. After beeing defined, we can use the `%Player{...}` syntax to create new structs or match on them.

Next, let's start coding our game, to do that let's go to `lib/tug_of_war.ex` and clean the boilerplate code and add:

```elixir
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
      {:ok, head_rope} -> TugOfWar.Team.pull(tug_of_war.team, head_rope)
    end

    # Let's return the %TugOfWar{} itself
    tug_of_war
  end
end
```
We created the `TugOfWar` struct to store the match teams and the basic functions for our game.

The `TugOfWar.set/3` (`/3` means the function expects three arguments) sets the rope for each team and returns the game struct.

Next we added the `TugOfWar.pull/1` that will make our team pull the rival team, let's see in action:

```elixir
# Start the teams
iex> TugOfWar.Team.start_link(:benfica)
{:ok, #PID<0.159.0>}
iex> TugOfWar.Team.start_link(:sporting)
{:ok, #PID<0.161.0>}

# Start the game
iex> tow = TugOfWar.set(:benfica, :sporting, 10)
%TugOfWar{rival_team: :sporting, team: :benfica}

# Check initial data
iex> TugOfWar.Team.get(:sporting)
[5, 6, 7, 8, 9]
iex> TugOfWar.Team.get(:benfica)
[4, 3, 2, 1, 0]

# Pull the rope
iex> TugOfWar.pull(tow)
%TugOfWar{rival_team: :sporting, team: :benfica}

# See the changes after the pull
iex> TugOfWar.Team.get(:sporting)
[6, 7, 8, 9]
iex> TugOfWar.Team.get(:benfica)
[5, 4, 3, 2, 1, 0]
```

The game seams to be working but it's borring to always do `TugOfWar.Team.get/1` to see the team status. It would be nice if our struct represent the actual game
