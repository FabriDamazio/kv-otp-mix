defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    # start_link_supervised linka o processo iniciado ao processo do teste
    # Isso garante que o processo vai ser desligado ANTES do próximo teste.
    %{registry: start_link_supervised!(KV.Registry)}
  end

  test "spawn buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "shopping") == :error

    KV.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "removes buckets on exit", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)

    assert KV.Registry.lookup(registry, "shopping") == :error
  end
end
