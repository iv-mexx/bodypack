defmodule BodyPack.Renderer do
  @moduledoc """
  Generates render commands based on new and old state
  at a constant frame rate
  """
  use GenStage

  @fps 60

  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    :timer.send_interval(trunc(1000 / @fps), self(), :tick)
    {:producer, []}
  end

  def handle_info(:tick, old_state) do
    # Get current State
    new_state = GenStage.call(BodyPack.OscToWs2812, :get_state, trunc(1000 / @fps))
    # Generate Render-Messages based on new and old state
    messages = BodyPack.Renderers.Sprout.ws2812messages_for_state(new_state, old_state)
    # Push render messages
    GenServer.cast(__MODULE__, {:add, messages})

    {:noreply, [], new_state}
  end

  def handle_cast({:add, events}, state) when is_list(events) do
    {:noreply, events, state}
  end

  def handle_cast({:add, events}, state), do: {:noreply, [events], state}

  def handle_demand(demand, state) do
    # We don't care about the demand
    IO.puts("Handle Demand #{demand}")
    {:noreply, [], state}
  end
end
