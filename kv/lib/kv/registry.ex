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
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  # Call é uma chamada síncrona
  @impl true
  def handle_call({:lookup, name}, _from, state) do
    {names, _} = state
    {:reply, Map.fetch(names, name), state}
  end

  # Cast é uma chamada assíncrona
  @impl true
  def handle_cast({:create, name}, {names, refs}) do
    if Map.has_key?(names, name) do
      {:noreply, {names, refs}}
    else
      {:ok, bucket} = KV.Bucket.start_link([])
      ref = Process.monitor(bucket)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, bucket)
      {:noreply, {names, refs}}
    end
  end

  # Info são todas outras mensagens que não sejam Cast ou Call.
  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  # Uma clausula que da match em todos é importante porque as mensagens Info
  # podem ficar paradas e até crashar o GenServer
  @impl true
  def handle_info(msg, state) do
    require Logger
    Logger.debug("Unexpected message in KV.Registry: #{inspect(msg)}")
    {:noreply, state}
  end

end
