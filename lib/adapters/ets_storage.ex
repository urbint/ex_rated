defmodule ExRated.Adapters.ETSStorage do
  @moduledoc """
  Implementation of the storage adapter for Erlang Term Storage (ETS).

  """

  @behaviour ExRated.Storage

  def initialize_store(store_name, false, storage_config) do
    # ETS expects the storage_config to be a list of atoms.
    config_list = for {key, _} <- storage_config, do: key

    :ets.new(store_name, config_list)
  end

  def initialize_store(store_name, true, storage_config) do
    # ETS expects the storage_config to be a list of atoms.
    config_list = for {key, _} <- storage_config, do: key

    :ets.new(store_name, config_list)
    :dets.open_file(store_name, [{:file, store_name}, {:repair, true}])
    :ets.delete_all_objects(store_name)
    :ets.from_dets(store_name, store_name)
  end

  def close(store_name) do
    :dets.close(store_name)
  end

  def contains(store_name, key) do
    :ets.member(store_name, key)
  end

  def get(store_name, key) do
    :ets.lookup(store_name, key)
  end

  def persist(store_name) do
    :ets.to_dets(store_name, store_name)
  end

  def delete_bucket_by_id(store_name, id) do
    import Ex2ms

    :ets.select_delete(store_name, fun do {{bucket_number, bid}, _, _, _} when bid == ^id -> true end)
  end

  def prune_expired_buckets(store_name, timeout) do
    alias ExRated.Helpers
    import Ex2ms

    now_stamp = Helpers.timestamp()

    :ets.select_delete(store_name, fun do {_,_,_,updated_at} when updated_at < (^now_stamp - ^timeout) -> true end)
  end

  def set(store_name, key_values) do
    :ets.insert(store_name, key_values)
  end

  def update_counter(store_name, key, limit, stamp) do
    case contains(store_name, key) do
      false ->
        set(store_name, {key, 1, stamp, stamp})
        {:ok, 1}

      true ->
        [counter, _, _] = :ets.update_counter(store_name, key, [{2, 1}, {3, 0}, {4, 1, 0, stamp}])

        if (counter > limit) do
          {:error, "Rate limit of #{limit} exceeded."}
        else
          {:ok, counter}
        end
    end
  end

end

