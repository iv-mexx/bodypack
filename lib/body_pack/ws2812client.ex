defmodule BodyPack.Ws2812Client do
  use GenStage
  require Logger

  @default_ws2812srv_ip 'localhost'
  @default_ws2812srv_port 9999

  @startup_sequence """
  reset;
  setup 1,16,3;
  init;
  do; fill 1,ff0000; render; delay 25; fill 1,000000; render; delay 50; loop 3;
  """

  def start_link(options \\ []) do
    ip = Keyword.get(options, :ws2812srv_ip, @default_ws2812srv_ip)
    port = Keyword.get(options, :ws2812srv_port, @default_ws2812srv_port)
    GenStage.start_link(__MODULE__, %{ip: ip, port: port}, name: __MODULE__)
  end

  def init(%{ip: ip, port: port}) do
    {:ok, socket} = :gen_tcp.connect(ip, port, [:binary])
    :ok = :gen_tcp.send(socket, @startup_sequence)
    {:consumer, socket, subscribe_to: [ExOsc.MessageBuffer]}
  end

  def send_message(message, timeout \\ 5000) do
    GenStage.call(__MODULE__, {:message, message}, timeout)
  end

  def handle_call({:message, message}, _from, socket) do
    :ok = :gen_tcp.send(socket, message)
    {:reply, :ok, [], socket}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      Logger.info("WS2812Client: #{inspect(event)}")
    end

    {:noreply, [], state}
  end
end
