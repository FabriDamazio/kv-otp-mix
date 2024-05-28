defmodule KV.Bucket do
  @moduledoc """
  Usado para guardar registros de pares de chave e valor.
  """

  # Injeta código contido na função __using__/1 do módulo Agent
  use Agent

  @doc """
  Inicia um novo bucket.
  """
  def start_link(_ops) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Retorna um valor do bucket pela chave (key).
  """
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Adiciona ou atualiza no bucket o valor relacionado a chave (key) informado.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Remove uma key e seu valor de um bucket.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end
end
