defmodule BodyPack.OscToWs2812 do
  use GenStage
  require Logger

  @max_value 255

  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    {:producer_consumer, :ok, subscribe_to: [ExOsc.MessageBuffer]}
  end

  def handle_events(events, _from, state) do

    event = List.last(events)

    {{"/docker/eyes/", [osc_float: brightness]}} = event

    brightness = floor(brightness * @max_value)

    # for event <- events do
    Logger.info("Brightness: #{brightness}")
    # end

    message = "brightness 1,#{brightness};"

    {:noreply, [message], state}
  end
end
