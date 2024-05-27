defmodule KV.MixProject do
  use Mix.Project

  # Retorna as configurações do projeto
  def project do
    [
      app: :kv,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Usado para gerar o arquivo da aplicação
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Define as dependências do projeto
  # Invocado da função project
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
