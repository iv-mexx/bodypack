defmodule DockerState do
  defstruct brightness: 0, red: 0, green: 0, blue: 0, bpm: 0, program: 0, step: 0
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
    previous_step = state.step
    state = Enum.reduce(events, state, fn event, acc -> handle_osc_message(event, acc) end)

    IO.inspect(state)
    # IO.inspect(ws2812messages_for_state(state, previous_step))

    {:noreply, ws2812messages_for_state(state, previous_step), state}
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
    %DockerState{state | program: round(program * 127)}
  end

  defp handle_osc_message({{"/docker/step", [osc_float: step]}}, state) do
    %DockerState{state | step: round(step * 127)}
  end

  defp handle_osc_message({{"/global/bpm", [osc_float: bpm]}}, state) do
    %DockerState{state | bpm: floor(bpm * @max_value)}
  end

  defp handle_osc_message(_, state), do: state

  defp ws2812messages_for_state(%{program: 0} = state, _) do
    [
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)};",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 1 = Rainbow BOTH
  defp ws2812messages_for_state(%{program: 1, step: 0} = state, _) do
    [
      "rainbow 1,2;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  defp ws2812messages_for_state(%{program: 1, step: step}, previous_step) when step > previous_step do
    [
      "rotate 1;",
      "render;"
    ]
  end

  # Program 2 = Rainbow LEFT
  defp ws2812messages_for_state(%{program: 2, step: 0} = state, _) do
    [
      "fill 1,000000;",
      "rainbow 1,2,0,255,1,16;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  defp ws2812messages_for_state(%{program: 2, step: step}, previous_step) when step > previous_step do
    [
      "rotate 1;",
      "render;"
    ]
  end

  # Program 3 = Random BOTH
  defp ws2812messages_for_state(%{program: 3, step: step} = state, previous_step) when step != previous_step do
    [
      "fill 1,000000;",
      "random 1,0,32,RGB;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 4 = Random LEFT
  defp ws2812messages_for_state(%{program: 4, step: step} = state, previous_step) when step != previous_step do
    [
      "fill 1,000000;",
      "random 1,0,16,RGB;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 5 = Random RIGHT
  defp ws2812messages_for_state(%{program: 5, step: step} = state, previous_step) when step != previous_step do
    [
      "fill 1,000000;",
      "random 1,16,16,RGB;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 10 = Random Fade In/Out - Step < 64 = start
  defp ws2812messages_for_state(%{program: 10, step: step}, _) when step < 64 do
    [
      "thread_start;",
      "random_fade_in_out 1,0;",
      "thread_stop;"
    ]
  end

  defp ws2812messages_for_state(%{program: 10}, _) do
    [
      "kill_thread;",
    ]
  end

  defp ws2812messages_for_state(_, _), do: []
end
