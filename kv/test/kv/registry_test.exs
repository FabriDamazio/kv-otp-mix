defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  # Não mais necessário porque mudou a implementação para user DynamicSupervisor
  #setup do
    # start_link_supervised linka o processo iniciado ao processo do teste
    # Isso garante que o processo vai ser desligado ANTES do próximo teste.
    #%{registry: start_link_supervised!(KV.Registry)}
  #end

  test "spawn buckets" do
    assert KV.Registry.lookup(KV.Registry, "shopping") == :error

    KV.Registry.create(KV.Registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(KV.Registry, "shopping")

    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "removes buckets on exit" do
    KV.Registry.create(KV.Registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(KV.Registry, "shopping")
    Agent.stop(bucket)

    assert KV.Registry.lookup(KV.Registry, "shopping") == :error
  end

  test "removes buckets on crash" do
    KV.Registry.create(KV.Registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(KV.Registry, "shopping")

    # Para o bucket com uma razão anormal
    Agent.stop(bucket, :shutdown)
    assert KV.Registry.lookup(KV.Registry, "shopping") == :error
  end
end
