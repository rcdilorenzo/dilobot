defmodule DiloBot.Mixfile do
  use Mix.Project

  def project do
    [app: :dilo_bot,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :slack, :porcelain, :poison, :ecto,
                    :postgrex, :cowboy, :plug, :table_rex, :basic_auth, :eex],
     mod: {DiloBot, []}]
  end

  defp deps do
    [
      {:slack, "~> 0.9.1"},
      {:porcelain, "~> 2.0"},
      {:poison, "~> 3.0"},
      {:table_rex, "~> 0.8"},
      {:ecto, "~> 2.0"},
      {:postgrex, "~> 0.11"},
      {:cowboy, "~> 1.0.0"},
      {:plug, "~> 1.0"},
      {:basic_auth, "~> 2.1"},
      {:distillery, "~> 1.0"}
    ]
  end
end
