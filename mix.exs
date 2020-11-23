defmodule BodyPack.MixProject do
  use Mix.Project

  def project do
    [
      app: :bodypack,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {BodyPack.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps() do
    [
      {:ex_osc,
       git: "https://github.com/iv-mexx/ex_osc.git",
       commit: "8ab99095c6482127d8c55f19f2246940a3ed3559"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:gen_stage, "~> 1.0"}
    ]
  end
end
