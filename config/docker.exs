import Config

config :bodypack,
  startup_sequence: """
  reset;
  setup 1,32,3;
  init;
  brightness 1,15;
  do; fill 1,0000ff; render; delay 25; fill 1,000000; render; delay 150; loop 5;
  fill 1,000080;
  brightness 1,5;
  render;
  """,
  renderer: BodyPack.Renderers.Docker

# Do not print debug messages in production
config :logger, level: :info
