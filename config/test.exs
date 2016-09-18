use Mix.Config

config :babble,
  time_source: Babble.Time.FakeTime

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :babble, Babble.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :babble, Babble.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "babble_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
