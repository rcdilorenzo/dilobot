defmodule DiloBot.Mixfile do
  use Mix.Project

  def project do
    [app: :dilo_bot,
     version: "0.3.0",
     elixir: "~> 1.8.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :porcelain, :poison, :ecto, :plug_cowboy,
                    :postgrex, :cowboy, :plug, :table_rex, :basic_auth, :eex, :httpotion],
     mod: {DiloBot, []}]
  end

  defp deps do
    [
      {:porcelain, "~> 2.0"},
      {:poison, "~> 3.0"},
      {:table_rex, "~> 0.8"},
      {:ecto, "~> 2.0"},
      {:postgrex, "~> 0.11"},
      {:cowboy, "~> 2.5"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.3"},
      {:basic_auth, "~> 2.1"},
      {:distillery, "~> 1.0"},
      {:httpotion, "~> 3.0"}
    ]
  end
end
