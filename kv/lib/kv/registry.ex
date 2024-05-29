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

  @doc """
  Inicia o Registry com as opções informadas.

  `:name` é obrigatório.
  """
  def start_link(opts) do
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end

  @doc """
  Procura o pid do bucket no server.

  Retorna `{:ok, pid}` se o Bucket existir ou `:error` se não for encontrado.
  """
  def lookup(server, name) do
    # Lookup é feito diretamente no ETS sem acessar o server.
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  @doc """
  Garante que um bucket tem um nome associado no server.
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  # GenServer Callbacks ------------------------------

  @impl true
  def init(table) do
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {names, refs}}
  end

  # Call é uma chamada síncrona
  # Não é mais necessária porque agora usamos ETS table
  # @impl true
  # def handle_call({:lookup, name}, _from, state) do
  #   {names, _} = state
  #   {:reply, Map.fetch(names, name), state}
  # end

  # Cast é uma chamada assíncrona
  @impl true
  def handle_call({:create, name}, _from, {names, refs}) do
    case lookup(names, name) do
      {:ok, pid} ->
        {:reply, pid, {names, refs}}

      :error ->
        {:ok, pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)
        :ets.insert(names, {name, pid})
        {:reply, pid, {names, refs}}
    end
  end

  # Info são todas outras mensagens que não sejam Cast ou Call.
  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
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
