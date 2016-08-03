defmodule Battleship.Player.Random do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_arg) do
    # Use a list of all possible valid coordinates as our state. We will then
    # take one coordinate from the list randomly on each turn.
    all_coordinates = for x <- 0..9, y <- 0..9, do: {x, y}
    state = %{remaining_coordinates: all_coordinates, ships_remaining: [5, 4, 3, 3, 2], last_shot: {0,0}}
    {:ok, state}
  end

  def handle_call(:name, _from, state) do
    {:reply, "Random", state}
  end

  def handle_call(:new_game, _from, state) do
    :random.seed(:erlang.now)
    fleet = [
      {5, 9, 5, :across},
      {6, 8, 4, :across},
      {7, 7, 3, :across},
      {7, 6, 3, :across},
      {8, 5, 2, :across}
    ]
    {:reply, fleet, state}
  end

  def pick_shot(:hit, state) do
    index = :random.uniform(Enum.count(state.remaining_coordinates)) - 1
    {Enum.at(state.remaining_coordinates, index), index}
  end

  def pick_shot(:miss, state) do
    index = :random.uniform(Enum.count(state.remaining_coordinates)) - 1
    {Enum.at(state.remaining_coordinates, index), index}
  end

  def pick_shot(:unknown, state) do
    index = :random.uniform(Enum.count(state.remaining_coordinates)) - 1
    {Enum.at(state.remaining_coordinates, index), index}
  end

  def handle_call({:take_turn, tracking_board, remaining_ships}, _from,
                  state) do

    last_x = elem(state.last_shot, 0)
    last_y = elem(state.last_shot, 1)
    last_shot_result = tracking_board 
                        |> Enum.at(last_x) 
                        |> Enum.at(last_y)
    {shot, index} = pick_shot(last_shot_result, state)

    remaining_coordinates = List.delete_at(state.remaining_coordinates, index)
    {:reply, shot, %{remaining_coordinates: remaining_coordinates, ships_remaining: remaining_ships, last_shot: shot}}
  end

end
