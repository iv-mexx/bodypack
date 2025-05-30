defmodule BodyPack.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, args) do
    children = [
      # {BodyPack.Listener, args},
      {BodyPack.OscToWs2812, args},
      {BodyPack.Renderer, args},
      {BodyPack.Ws2812Client, args}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BodyPack.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
