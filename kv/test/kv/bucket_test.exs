defmodule KV.BucketTest do
  # Importa diversas funcionalidades de teste como a macro test/2
  # A opção async:true indica a execução dos testes em paralelo
  # Não deve ser usada em teste que modificam valores globais
  use ExUnit.Case, async: true

  setup do
    # start_link_supervised linka o processo iniciado ao processo do teste
    # Isso garante que o processo vai ser desligado ANTES do próximo teste.
    %{bucket: start_link_supervised!(KV.Bucket)}
  end

  test "stores values by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  test "removes a value by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3

    KV.Bucket.delete(bucket, "milk")
    assert KV.Bucket.get(bucket, "milk") == nil
  end
end
