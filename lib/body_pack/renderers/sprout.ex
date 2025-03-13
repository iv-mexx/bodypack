defmodule BodyPack.Renderers.Sprout do
  @segment_1 "0,46"
  @segment_2 "46,32"
  @segment_3 "78,26"
  @segment_4 "104,45"
  @segment_5 "149,40"
  @segment_6 "189,20"

  defp format_color(%{red: red, green: green, blue: blue}) do
    "#{format_color(red)}#{format_color(green)}#{format_color(blue)}"
  end

  defp format_color(color) do
    color
    |> Integer.to_string(16)
    |> String.pad_leading(2, "0")
  end

  def ws2812messages_for_state(%{reset: reset}, %{reset: previous_reset})
      when previous_reset < 125 and reset >= 125 do
    [
      "reset;",
      "setup 1,209,3;",
      "init;"
    ]
  end

  # Switch to program 9 - Chaser
  def ws2812messages_for_state(%{program: 9, step: step} = state, %{program: previous_program})
      when previous_program != 9 do
    [
      "thread_start;",
      "chaser 1,0,#{format_color(state)},#{step};",
      "thread_stop;"
    ]
  end

  # Switch away from program 9 - stop thread
  def ws2812messages_for_state(%{program: program}, %{program: 9}) when program != 9 do
    [
      "kill_thread;"
    ]
  end

  # Switch to program 10 - start random fade thread
  def ws2812messages_for_state(%{program: 10}, %{program: previous_program})
      when previous_program != 10 do
    [
      "thread_start;",
      "random_fade_in_out 1,0;",
      "thread_stop;"
    ]
  end

  # Switch away from program 10 - stop thread
  def ws2812messages_for_state(%{program: program}, %{program: 10}) when program != 10 do
    [
      "kill_thread;"
    ]
  end

  def ws2812messages_for_state(%{program: 0, step: 0} = state, _) do
    [
      "fill 1,#{format_color(state)};",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 1 with Step increasing = Rotate forward
  def ws2812messages_for_state(%{program: 1, step: step} = state, %{step: previous_step})
      when step > previous_step do
    [
      "rotate 1,1,0;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 1 with Step decreasing = Rotate backwards
  def ws2812messages_for_state(%{program: 1, step: step} = state, %{step: previous_step})
      when step < previous_step do
    [
      "rotate 1,1,1;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 3 = Random BOTH
  def ws2812messages_for_state(%{program: 3, step: step} = state, %{step: previous_step})
      when step != previous_step do
    [
      "fill 1,000000;",
      "random 1,0,209,RGB;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 4 = Random LEFT
  def ws2812messages_for_state(%{program: 4, step: step} = state, %{step: previous_step})
      when step != previous_step do
    [
      "fill 1,000000;",
      "random 1,0,16,RGB;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 5 = Random RIGHT
  def ws2812messages_for_state(%{program: 5, step: step} = state, %{step: previous_step})
      when step != previous_step do
    [
      "fill 1,000000;",
      "random 1,16,16,RGB;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 11 = Random Brightness BOTH
  def ws2812messages_for_state(%{program: 11, step: step}, %{step: previous_step})
      when step != previous_step do
    [
      "random 1,0,209,L;",
      "render;"
    ]
  end

  # Program 12 = Brightness Gradient
  def ws2812messages_for_state(%{program: 12, step: step} = state, _) when step < 64 do
    [
      "fill 1,#{format_color(state)};",
      "brightness 1,#{state.brightness};",
      "gradient 1,L,0,#{state.brightness},0,209;",
      "render;"
    ]
  end

  # Program 13 = Gaps
  def ws2812messages_for_state(%{program: 13, step: step} = state, _) do
    [
      "brightness 1,#{state.brightness};",
      "fill 1,000000,1,209;",
      "fill 1,#{format_color(state)},0,#{step};",
      "fill 1,#{format_color(state)},8,#{step};",
      "fill 1,#{format_color(state)},16,#{step};",
      "fill 1,#{format_color(state)},24,#{step};",
      "fill 1,#{format_color(state)},32,#{step};",
      "fill 1,#{format_color(state)},40,#{step};",
      "fill 1,#{format_color(state)},48,#{step};",
      "fill 1,#{format_color(state)},56,#{step};",
      "fill 1,#{format_color(state)},64,#{step};",
      "fill 1,#{format_color(state)},72,#{step};",
      "fill 1,#{format_color(state)},80,#{step};",
      "fill 1,#{format_color(state)},88,#{step};",
      "fill 1,#{format_color(state)},96,#{step};",
      "fill 1,#{format_color(state)},104,#{step};",
      "fill 1,#{format_color(state)},112,#{step};",
      "fill 1,#{format_color(state)},120,#{step};",
      "fill 1,#{format_color(state)},128,#{step};",
      "fill 1,#{format_color(state)},136,#{step};",
      "fill 1,#{format_color(state)},144,#{step};",
      "fill 1,#{format_color(state)},152,#{step};",
      "fill 1,#{format_color(state)},160,#{step};",
      "fill 1,#{format_color(state)},168,#{step};",
      "fill 1,#{format_color(state)},176,#{step};",
      "fill 1,#{format_color(state)},184,#{step};",
      "fill 1,#{format_color(state)},192,#{step};",
      "fill 1,#{format_color(state)},200,#{step};",
      "render;"
    ]
  end

  # Program 14 = Gaps with Inverted Colors
  def ws2812messages_for_state(%{program: 14, step: step} = state, _) do
    [
      "brightness 1,#{state.brightness};",
      "fill 1,000000,1,209;",
      "fill 1,#{format_color(state)},0,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},8,#{step};",
      "fill 1,#{format_color(state)},16,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},24,#{step};",
      "fill 1,#{format_color(state)},32,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},40,#{step};",
      "fill 1,#{format_color(state)},48,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},56,#{step};",
      "fill 1,#{format_color(state)},64,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},72,#{step};",
      "fill 1,#{format_color(state)},80,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},88,#{step};",
      "fill 1,#{format_color(state)},96,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},104,#{step};",
      "fill 1,#{format_color(state)},112,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},120,#{step};",
      "fill 1,#{format_color(state)},128,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},136,#{step};",
      "fill 1,#{format_color(state)},144,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},152,#{step};",
      "fill 1,#{format_color(state)},160,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},168,#{step};",
      "fill 1,#{format_color(state)},176,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},184,#{step};",
      "fill 1,#{format_color(state)},192,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},200,#{step};",
      "render;"
    ]
  end

  # Program 15 = Segments
  def ws2812messages_for_state(%{program: 15, step: step} = state, _) do
    segment = rem(step, 6)

    [
      "brightness 1,#{state.brightness};",
      "fill 1,#{if segment == 0, do: format_color(state), else: "000000"},#{@segment_1};",
      "fill 1,#{if segment == 1, do: format_color(state), else: "000000"},#{@segment_2};",
      "fill 1,#{if segment == 2, do: format_color(state), else: "000000"},#{@segment_3};",
      "fill 1,#{if segment == 3, do: format_color(state), else: "000000"},#{@segment_4};",
      "fill 1,#{if segment == 4, do: format_color(state), else: "000000"},#{@segment_5};",
      "fill 1,#{if segment == 5, do: format_color(state), else: "000000"},#{@segment_6};",
      "render;"
    ]
  end

  # Program 20 = Rainbow BOTH
  def ws2812messages_for_state(%{program: 20, step: 0} = state, _) do
    [
      "rainbow 1,2;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 21 = Rainbow LEFT
  def ws2812messages_for_state(%{program: 21, step: 0} = state, _) do
    [
      "fill 1,000000;",
      "rainbow 1,2,0,255,1,16;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 22 = Rainbow RIGHT
  def ws2812messages_for_state(%{program: 22, step: 0} = state, _) do
    [
      "fill 1,000000;",
      "rainbow 1,2,0,255,16,16;",
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  # Program 23 = Brightness Gradient rotated by step
  def ws2812messages_for_state(%{program: 23, step: step} = state, %{step: previous_step})
      when step != previous_step do
    progress = step / 127.0

    [
      "fill 1,#{format_color(state)};",
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
  def ws2812messages_for_state(%{program: 24, step: step} = state, _) when rem(step, 2) == 0 do
    [
      "brightness 1,#{state.brightness};",
      "render;"
    ]
  end

  def ws2812messages_for_state(%{program: 24}, _) do
    [
      "brightness 1,0;",
      "render;"
    ]
  end

  def ws2812messages_for_state(_, _), do: []
end
