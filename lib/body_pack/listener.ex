defmodule BodyPack.Listener do
  @moduledoc """
  GenServer process to listen for OSC messages
  """
  use GenStage

  require Logger

  def start_link(options \\ []) do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(options) do
    {:consumer, :ok, subscribe_to: [ExOsc.MessageBuffer]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      Logger.info("Listener: #{inspect(event)}")
    end

    {:noreply, [], state}
  end
end
