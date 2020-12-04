defmodule DockerState do
  defstruct brightness: 0, red: 0, green: 0, blue: 0
end

defmodule BodyPack.OscToWs2812 do
  use GenStage
  require Logger

  @max_value 255

  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    {:producer_consumer, %DockerState{}, subscribe_to: [ExOsc.MessageBuffer]}
  end

  def handle_events(events, _from, state) do
    state = Enum.reduce(events, state, fn event, acc -> handle_osc_message(event, acc) end )
    message = "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)}; brightness 1,#{state.brightness};"

    IO.puts message

    {:noreply, [message], state}
  end

  defp format_color(color) do
    color
    |> Integer.to_string(16)
    |> String.pad_leading(2, "0")
  end

  defp handle_osc_message({{"/docker/eyes/brightness", [osc_float: brightness]}}, state) do
    %DockerState{ state | brightness: floor(brightness * @max_value)}
  end

  defp handle_osc_message({{"/docker/eyes/red", [osc_float: red]}}, state) do
    %DockerState{ state | red: floor(red * @max_value)}
  end

  defp handle_osc_message({{"/docker/eyes/green", [osc_float: green]}}, state) do
    %DockerState{ state | green: floor(green * @max_value)}
  end

  defp handle_osc_message({{"/docker/eyes/blue", [osc_float: blue]}}, state) do
    %DockerState{ state | blue: floor(blue * @max_value)}
  end

  defp handle_osc_message(msg, state) do
    IO.puts "Unmatched message"
    IO.inspect msg
    IO.puts "-----"
    state
  end
end
