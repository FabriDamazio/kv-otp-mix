defmodule KV.Registry do
  @moduledoc """
  Mantem um registro de todos os buckets criados.
  Todo bucket criado possui um nome associado a ele.
  """

  use GenServer

  # Client API -------------------------------------
  # As operações pesadas devem serem realizadas antes de enviar uma mensagem
  # para o server, porque se executadas no server as outras requests ficaram
  # experando podendo dar timeout

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Procura o pid do bucket no server.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc"""
  Garante que um bucket tem um nome associado no server.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  # GenServer Callbacks ------------------------------
  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  # Call é uma chamada síncrona
  @impl true
  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  # Cast é uma chamada assíncrona
  @impl true
  def handle_cast({:create, name}, names) do
    if Map.has_key?(names, name) do
      {:noreply, names}
    else
      {:ok, bucket} = KV.Bucket.start_link([])
      {:noreply, Map.put(names, name, bucket)}
    end
  end
end
