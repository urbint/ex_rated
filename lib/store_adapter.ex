defmodule ExRated.Storage do
  @moduledoc """
  Adapter for plug-in storage.

  """

  @engine Application.get_env(:ex_rated, :storage_adapter, ExRated.Adapters.ETSStorage)

  @doc """
  Initializes the storage service.

  """
  @callback initialize_store(
    store_name  :: :atom,
    persistent? :: boolean
  ) :: :ok | {:error, reason :: String.t}
  @spec initialize_store(
    store_name  :: :atom,
    persistent? :: boolean
  ) :: :ok | {:error, reason :: String.t}
  def initialize_store(store_name, persistent?) do
    @engine.initialize_store(store_name, persistent?)
  end

  @doc """
  Closes the connection to the datastore.

  """
  @callback close(
    store_name :: :atom
  ) :: :ok | {:error, reason :: String.t}
  @spec close(
    store_name :: :atom
  ) :: :ok | {:error, reason :: String.t}
  def close(store_name) do
    @engine.close(store_name)
  end

  @doc """
  Queries the datastore for the existence of a value or values stored at the specified key.

  """
  @callback contains(
    store_name :: :atom,
    key        :: tuple
  ) :: :ok | {:error, reason :: String.t}
  @spec contains(
    store_name :: :atom,
    key        :: tuple
  ) :: :ok | {:error, reason :: String.t}
  def contains(store_name, key) do
    @engine.contains(store_name, key)
  end

  @doc """
  Retrieves key-value pairs from the storage service.

  """
  @callback get(
    store_name :: :atom,
    key        :: :atom
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  @spec get(
    store_name :: :atom,
    key        :: :atom
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  def get(store_name, key) do
    @engine.get(store_name, key)
  end

  @doc """
  Persists in-memory storage to a file.
  NOTE: May be specific to ETS and not other datastores.

  """
  @callback persist(
    store_name :: :atom
  ) :: :ok | {:error, reason :: String.t}
  @spec persist(
    store_name :: :atom
  ) :: :ok | {:error, reason :: String.t}
  def persist(store_name) do
    @engine.persist(store_name)
  end

  @doc """
  Deletes a bucket specified by a unique identifier.

  """
  @callback delete_bucket_by_id(
    store_name :: :atom,
    id         :: any
  ) :: :ok | {:error, reason :: String.t}
  @spec delete_bucket_by_id(
    store_name :: :atom,
    id         :: any
  ) :: :ok | {:error, reason :: String.t}
  def delete_bucket_by_id(store_name, id) do
    @engine.delete_bucket_by_id(store_name, id)
  end

  @doc """
  Saves key-value pairs to the storage service.

  """
  @callback set(
    store_name     :: :atom,
    key_value_pair :: tuple
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  @spec set(
    store_name     :: :atom,
    key_value_pair :: tuple
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  def set(store_name, key_value_pair) do
    @engine.set(store_name, key_value_pair)
  end

  @doc """
  Removes old buckets and returns the number removed.

  """
  @callback prune_expired_buckets(
    store_name :: :atom,
    timeout    :: non_neg_integer
  ) :: {:ok, num_pruned :: non_neg_integer} | {:error, reason :: String.t}
  @spec prune_expired_buckets(
    store_name :: :atom,
    timeout    :: non_neg_integer
  ) :: {:ok, num_pruned :: non_neg_integer} | {:error, reason :: String.t}
  def prune_expired_buckets(store_name, timeout) do
    @engine.prune_expired_buckets(store_name, timeout)
  end

  @doc """
  Increments the access counter.

  """
  @callback update_counter(
    store_name :: :atom,
    key        :: :atom,
    limit      :: non_neg_integer,
    stamp      :: non_neg_integer
  ) :: {:ok, new_count :: non_neg_integer} | {:error, reason :: String.t}
  @spec update_counter(
    store_name :: :atom,
    key        :: :atom,
    limit      :: non_neg_integer,
    stamp      :: non_neg_integer
  ) :: {:ok, new_count :: non_neg_integer} | {:error, reason :: String.t}
  def update_counter(store_name, key, limit, stamp) do
    @engine.update_counter(store_name, key, limit, stamp)
  end

end

