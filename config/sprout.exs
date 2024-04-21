import Config

config :bodypack,
  startup_sequence: """
    reset;
    setup 1,209,3;
    init;
    brightness 1,15;
    do; fill 1,00ff00; render; delay 25; fill 1,000000; render; delay 150; loop 5;
    fill 1,000080;
    brightness 1,5;
    render;
  """,
  renderer: BodyPack.Renderers.Sprout

# Do not print debug messages in production
config :logger, level: :info
