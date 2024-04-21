import Config

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

IO.inspect(config_env())

import_config "#{config_env()}.exs"
