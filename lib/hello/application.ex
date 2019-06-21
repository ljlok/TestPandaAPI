defmodule Hello.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    import Supervisor.Spec, warn: false
    children = [
      # Start the Ecto repository
      Hello.Repo,
      # Start the endpoint when the application starts
      HelloWeb.Endpoint,
      # Starts a worker by calling: Hello.Worker.start_link(arg)
      # {Hello.Worker, arg},
      # MatchCache.Supervisor,
      supervisor(MatchCache.Supervisor, []),

    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hello.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HelloWeb.Endpoint.config_change(changed, removed)
    :ok
  end

end

defmodule MyServer do
  @my_data 11
  def first_data, do: @my_data
  @my_data 13
  def second_data, do: @my_data
end