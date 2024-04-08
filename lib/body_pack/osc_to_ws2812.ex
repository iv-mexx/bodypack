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
    {:producer_consumer, %DockerState{}, subscribe_to: [ExOsc.MessageBuffer]}
  end

  def handle_events(events, _from, state) do
    previous_state = state
    state = Enum.reduce(events, state, fn event, acc -> handle_osc_message(event, acc) end)

    # IO.inspect(state)
    # IO.inspect(ws2812messages_for_state(state, previous_state))

    {:noreply, ws2812messages_for_state(state, previous_state), state}
  end

  defp format_color(color) do
    color
    |> Integer.to_string(16)
    |> String.pad_leading(2, "0")
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

  defp ws2812messages_for_state(%{reset: reset}, %{reset: previous_reset})
       when previous_reset < 125 and reset >= 125 do
    [
      "reset;",
      "setup 1,209,3;",
      "init;"
    ]
  end

  # Switch to program 10 - start random fade thread
  defp ws2812messages_for_state(%{program: 10}, %{program: previous_program})
       when previous_program != 10 do
    [
      "thread_start;",
      "random_fade_in_out 1,0;",
      "thread_stop;"
    ]
  end

  # Switch away from program 10 - stop thread
  defp ws2812messages_for_state(%{program: program}, %{program: 10}) when program != 10 do
    [
      "kill_thread;"
    ]
  end

  defp ws2812messages_for_state(%{program: 0, step: 0} = state, _) do
    [
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)};",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 1 with Step increasing = Rotate forward
  defp ws2812messages_for_state(%{program: 1, step: step} = state, %{step: previous_step})
       when step > previous_step do
    [
      "rotate 1,1,0;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 1 with Step decreasing = Rotate backwards
  defp ws2812messages_for_state(%{program: 1, step: step} = state, %{step: previous_step})
       when step < previous_step do
    [
      "rotate 1,1,1;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 3 = Random BOTH
  defp ws2812messages_for_state(%{program: 3, step: step} = state, %{step: previous_step})
       when step != previous_step do
    [
      "fill 1,000000;",
      "random 1,0,209,RGB;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 4 = Random LEFT
  defp ws2812messages_for_state(%{program: 4, step: step} = state, %{step: previous_step})
       when step != previous_step do
    [
      "fill 1,000000;",
      "random 1,0,16,RGB;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 5 = Random RIGHT
  defp ws2812messages_for_state(%{program: 5, step: step} = state, %{step: previous_step})
       when step != previous_step do
    [
      "fill 1,000000;",
      "random 1,16,16,RGB;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 11 = Random Brightness BOTH
  defp ws2812messages_for_state(%{program: 11, step: step}, %{step: previous_step})
       when step != previous_step do
    [
      "random 1,0,209,L;",
      "render;"
    ]
  end

  # Program 12 = Brightness Gradient
  defp ws2812messages_for_state(%{program: 12, step: step} = state, _) when step < 64 do
    [
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)};",
      "brightness 1,#{state.brightness};",
      "gradient 1,L,0,#{state.brightness},0,209;",
      "render;"
    ]
  end

  # Program 13 = Gaps
  defp ws2812messages_for_state(%{program: 13, step: step} = state, _) do
    [
      "brightness 1,#{state.brightness};",
      "fill 1,000000,1,209;",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},0,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},8,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},16,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},24,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},32,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},40,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},48,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},56,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},64,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},72,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},80,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},88,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},96,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},104,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},112,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},120,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},128,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},136,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},144,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},152,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},160,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},168,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},176,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},184,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},192,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},200,#{step};",
      "render;"
    ]
  end

  # Program 14 = Gaps with Inverted Colors
  defp ws2812messages_for_state(%{program: 14, step: step} = state, _) do
    [
      "brightness 1,#{state.brightness};",
      "fill 1,000000,1,209;",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},0,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},8,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},16,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},24,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},32,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},40,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},48,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},56,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},64,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},72,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},80,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},88,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},96,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},104,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},112,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},120,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},128,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},136,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},144,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},152,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},160,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},168,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},176,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},184,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},192,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},200,#{step};",
      "render;"
    ]
  end

  # Program 20 = Rainbow BOTH
  defp ws2812messages_for_state(%{program: 20, step: 0} = state, _) do
    [
      "rainbow 1,2;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 21 = Rainbow LEFT
  defp ws2812messages_for_state(%{program: 21, step: 0} = state, _) do
    [
      "fill 1,000000;",
      "rainbow 1,2,0,255,1,16;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 22 = Rainbow RIGHT
  defp ws2812messages_for_state(%{program: 22, step: 0} = state, _) do
    [
      "fill 1,000000;",
      "rainbow 1,2,0,255,16,16;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 23 = Brightness Gradient rotated by step
  defp ws2812messages_for_state(%{program: 23, step: step} = state, %{step: previous_step})
       when step != previous_step do
    progress = step / 127.0

    [
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)};",
      "brightness 1,0;",
      "brightness 1,#{state.brightness},189,20;",
      "brightness 1,#{state.brightness * (2.0 * max(0.0, progress - 0.5))},149,40;",
      "gradient 1,L,0,#{state.brightness},#{46 - progress * 46},#{progress * 46};",
      "gradient 1,L,#{state.brightness},0,104,#{progress * 45};",
      "gradient 1,L,#{state.brightness},0,46,#{progress * 32};",
      "gradient 1,L,0,#{state.brightness},#{104 - progress * 26},#{progress * 26};",
      "render;"
    ]
  end

  # Program 24 = Strobe (with increasing step)
  defp ws2812messages_for_state(%{program: 24, step: step} = state, _) when rem(step, 2) == 0 do
    [
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  defp ws2812messages_for_state(%{program: 24}, _) do
    [
      "brightness 1,0;",
      "render;"
    ]
  end

  defp ws2812messages_for_state(_, _), do: []
end
