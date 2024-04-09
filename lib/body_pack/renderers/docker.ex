defmodule BodyPack.Renderers.Docker do
  def format_color(color) do
    color
    |> Integer.to_string(16)
    |> String.pad_leading(2, "0")
  end

  def ws2812messages_for_state(%{reset: reset}, %{reset: previous_reset})
      when previous_reset < 125 and reset >= 125 do
    [
      "reset;",
      "setup 1,32,3;",
      "init;"
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
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)};",
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
      "random 1,0,32,RGB;",
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
      "random 1,0,32,L;",
      "render;"
    ]
  end

  # Program 12 = Brightness Gradient
  def ws2812messages_for_state(%{program: 12, step: step} = state, _) when step < 64 do
    [
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)};",
      "brightness 1,#{state.brightness};",
      "gradient 1,L,0,#{state.brightness},1,16;",
      "gradient 1,L,0,#{state.brightness},16,16;",
      "render;"
    ]
  end

  # Program 13 = Gaps
  def ws2812messages_for_state(%{program: 13, step: step} = state, _) do
    [
      "brightness 1,#{state.brightness};",
      "fill 1,000000,1,32;",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},0,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},8,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},16,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},24,#{step};",
      "render;"
    ]
  end

  # Program 14 = Gaps with Inverted Colors
  def ws2812messages_for_state(%{program: 14, step: step} = state, _) do
    [
      "brightness 1,#{state.brightness};",
      "fill 1,000000,1,32;",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},0,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},8,#{step};",
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)},16,#{step};",
      "fill 1,#{format_color(255 - state.red)}#{format_color(255 - state.green)}#{format_color(255 - state.blue)},24,#{step};",
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
    [
      "fill 1,#{format_color(state.red)}#{format_color(state.green)}#{format_color(state.blue)};",
      "brightness 1,#{state.brightness};",
      "gradient 1,L,0,#{state.brightness},1,16;",
      "gradient 1,L,0,#{state.brightness},16,16;",
      "rotate 1,#{rem(step, 16)},1;",
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
