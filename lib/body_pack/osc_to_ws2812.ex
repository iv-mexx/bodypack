defmodule DockerState do
  defstruct brightness: 0, red: 0, green: 0, blue: 0, bpm: 0, program: 0
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
    state = Enum.reduce(events, state, fn event, acc -> handle_osc_message(event, acc) end)
    {:noreply, ws2812messages_for_state(state), state}
  end

  defp format_color(color) do
    color
    |> Integer.to_string(16)
    |> String.pad_leading(2, "0")
  end

  defp handle_osc_message({{"/docker/eyes/brightness", [osc_float: brightness]}}, state) do
    %DockerState{state | brightness: floor(brightness * @max_value)}
  end

  defp handle_osc_message({{"/docker/eyes/red", [osc_float: red]}}, state) do
    %DockerState{state | red: floor(red * @max_value)}
  end

  defp handle_osc_message({{"/docker/eyes/green", [osc_float: green]}}, state) do
    %DockerState{state | green: floor(green * @max_value)}
  end

  defp handle_osc_message({{"/docker/eyes/blue", [osc_float: blue]}}, state) do
    %DockerState{state | blue: floor(blue * @max_value)}
  end

  defp handle_osc_message({{"/docker/program", [osc_float: program]}}, state) do
    %DockerState{state | program: floor(program * 127)}
  end

  defp handle_osc_message({{"/global/bpm", [osc_float: bpm]}}, state) do
    %DockerState{state | bpm: floor(bpm * @max_value)}
  end

  defp handle_osc_message(_, state), do: state

  defp ws2812messages_for_state(%{program: 0} = state) do
    [
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)};",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  defp ws2812messages_for_state(%{program: 1} = state) do
    [
      "rainbow 1,2;",
      "brightness 1,#{state.brightness};",
      "do; rotate 1; render; delay 25; loop 150;"
    ]
  end

  defp ws2812messages_for_state(_), do: []
end
