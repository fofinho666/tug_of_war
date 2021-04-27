# TugOfWar

The goal of this project is to get a first contact with Elixir what this amazing programing language brings out of the box by using the Erlang virtual machine.

We'll start by covering some basics of the language and by the end, we'll be fighting for a list of numbers with someone else on our local network.

May the strong IEx wins!
## Table of content
- [Instalation](#Instalation)
- [IEx and basic data types](#IEx-and-basic-data-types)
- [Pattern matching](#Pattern-matching)
- [Functions and the pipe operator](#Functions-and-the-pipe-operator)
- [Let's create our project](#Lets-create-our-project)

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
iex> # I'm forgot a space"
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