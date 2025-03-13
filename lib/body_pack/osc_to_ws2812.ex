defmodule DockerState do
  defstruct brightness: 0,
            red: 0,
            green: 0,
            blue: 0,
            bpm: 0,
            program: 0,
            step: 0,
            reset: 0
end

defmodule BodyPack.OscToWs2812 do
  use GenStage
  require Logger

  @max_value 255

  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    {:consumer, %DockerState{}, subscribe_to: [ExOsc.MessageBuffer]}
  end

  def handle_events(events, _from, state) do
    state = Enum.reduce(events, state, fn event, acc -> handle_osc_message(event, acc) end)
    {:noreply, [], state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, [], state}
  end

  defp handle_osc_message({{"/brightness", [osc_float: brightness]}}, state) do
    %DockerState{state | brightness: floor(brightness * @max_value)}
  end

  defp handle_osc_message({{"/red", [osc_float: red]}}, state) do
    %DockerState{state | red: floor(red * @max_value)}
  end

  defp handle_osc_message({{"/green", [osc_float: green]}}, state) do
    %DockerState{state | green: floor(green * @max_value)}
  end

  defp handle_osc_message({{"/blue", [osc_float: blue]}}, state) do
    %DockerState{state | blue: floor(blue * @max_value)}
  end

  defp handle_osc_message({{"/program", [osc_float: program]}}, state) do
    %DockerState{state | program: round(program * 127)}
  end

  defp handle_osc_message({{"/program/step", [osc_float: step]}}, state) do
    %DockerState{state | step: round(step * 127)}
  end

  defp handle_osc_message({{"/bpm", [osc_float: bpm]}}, state) do
    %DockerState{state | bpm: floor(bpm * @max_value)}
  end

  defp handle_osc_message({{"/reset", [osc_float: reset]}}, state) do
    %DockerState{state | reset: floor(reset * @max_value)}
  end

  defp handle_osc_message(_, state), do: state
end
