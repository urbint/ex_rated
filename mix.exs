defmodule ExRated.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_rated,
     version: "1.2.2",
     elixir: "~> 1.2",
     description: description,
     package: package,
     deps: deps,
     name: "ExRated",
     source_url: "https://github.com/grempe/ex_rated",
     homepage_url: "https://github.com/grempe/ex_rated",
     docs: [extras: ["README.md"]]]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  #
  # timeout :        bucket maximum lifetime (90_000_000, 25 hours)
  # cleanup_rate :   cleanup every X milliseconds (60_000, every 1 minute)
  # ets_table_name : the registered name of the ETS table where buckets are stored.
  def application do
    [applications: [:logger],
     env: [
       timeout:       90_000_000,
       cleanup_rate:  60_000,
       table_name:    :ex_rated_buckets,
       persistent:    false
     ],
     mod: {ExRated.App, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:ex2ms, "~> 1.4.0"},
     {:ex_doc, "~> 0.11", only: :dev}]
  end

  defp description do
    """
    ExRated, the OTP GenServer with the naughty name that allows you to rate-limit calls
    to any service that requires it.

    For example, rate-limit calls to your favorite API which requires no more
    than `limit` API calls within a `scale` milliseconds time window. You can enforce
    limits for windows as narrow as milliseconds, or as broad as you like.
    """
  end

  defp package do
    [# These are the default files included in the package
     files: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Glenn Rempe"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/grempe/ex_rated"}]
  end

end
