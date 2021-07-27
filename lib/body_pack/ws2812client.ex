defmodule BodyPack.Ws2812Client do
  use GenStage
  require Logger

  # @default_ws2812srv_ip '127.0.0.1'
  @default_ws2812srv_ip '192.168.1.149'
  @default_ws2812srv_port 9998

  @startup_sequence """
  reset;
  setup 1,32,3;
  init;
  brightness 1,15;
  do; fill 1,ff0000; render; delay 25; fill 1,000000; render; delay 150; loop 3;
  fill 1,ff0000;
  brightness 1,0;
  render;
  """

  def start_link(options \\ []) do
    ip = Keyword.get(options, :ws2812srv_ip, @default_ws2812srv_ip)
    port = Keyword.get(options, :ws2812srv_port, @default_ws2812srv_port)
    GenStage.start_link(__MODULE__, %{ip: ip, port: port}, name: __MODULE__)
  end

  def init(%{ip: ip, port: port}) do
    {:ok, socket} = :gen_tcp.connect(ip, port, [:binary])
    :ok = :gen_tcp.send(socket, @startup_sequence)
    {:consumer, socket, subscribe_to: [BodyPack.OscToWs2812]}
  end

  def send_message(message, timeout \\ 5000) do
    GenStage.call(__MODULE__, {:message, message}, timeout)
  end

  def handle_call({:message, message}, _from, socket) do
    :ok = :gen_tcp.send(socket, message)
    {:reply, :ok, [], socket}
  end

  def handle_events(messages, _from, socket) do
    message = Enum.join(messages, "")

    IO.puts(message)

    :ok = :gen_tcp.send(socket, message)

    {:noreply, [], socket}
  end
end
