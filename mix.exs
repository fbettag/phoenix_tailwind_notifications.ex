defmodule PhoenixTailwindNotifications.MixProject do
  use Mix.Project

  @project_url "https://github.com/fbettag/phoenix_tailwind_notifications.ex"

  def project do
    [
      app: :phoenix_tailwind_notifications,
      version: "0.1.2",
      elixir: "~> 1.7",
      source_url: @project_url,
      homepage_url: @project_url,
      name: "Phoenix Tailwind Notifications",
      description: "Tailwind Notifications for Phoenix Applications",
      package: package(),
      aliases: aliases(),
      deps: deps()
    ]
  end

  defp package do
    [
      name: "phoenix_tailwind_notifications",
      maintainers: ["Franz Bettag"],
      licenses: ["MIT"],
      links: %{"GitHub" => @project_url},
      files: ~w(lib LICENSE README.md mix.exs)
    ]
  end

  defp aliases do
    [credo: "credo -a --strict"]
  end

  defp deps do
    [
      {:phoenix_live_view, "~> 0.15"},
      {:ex_doc, "~> 0.19", only: :dev},
      {:credo, github: "rrrene/credo", only: [:dev, :test]}
    ]
  end
end
