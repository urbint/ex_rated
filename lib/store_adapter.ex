defmodule ExRated.Storage do
  @moduledoc """
  Adapter for plug-in storage.

  """

  @engine Application.get_env(:ex_rated, :storage_adapter, ETSStorage)

  @doc """
  Initializes the storage service.

  """
  @callback initialize_store(
    store_name  :: String.t,
    persistent? :: boolean,
    options :: List # List of atoms
  ) :: :ok | {:error, reason :: String.t}
  @spec initialize_store(
    store_name  :: String.t,
    persistent? :: boolean,
    options :: List # List of atoms
  ) :: :ok | {:error, reason :: String.t}
  def initialize_store(store_name, persistent?, options) do
    @engine.initialize_store(store_name, persistent?, options)
  end

  @doc """
  Closes the connection to the datastore.
  NOTE: May be specific to ETS and not other datastores.

  """
  @callback close(
    store_name :: String.t
  ) :: :ok | {:error, reason :: String.t}
  @spec close(
    store_name :: String.t
  ) :: :ok | {:error, reason :: String.t}
  def close(store_name) do
    @engine.close(store_name)
  end

  @doc """
  Queries the datastore for the existence of a value or values stored at the specified key.

  """
  @callback contains(
    store_name :: String.t,
    key        :: String.t
  ) :: :ok | {:error, reason :: String.t}
  @spec contains(
    store_name :: String.t,
    key        :: String.t
  ) :: boolean
  def contains(store_name, key) do
    @engine.contains(store_name, key)
  end

  @doc """
  Retrieves key-value pairs from the storage service.

  """
  @callback get(
    store_name :: String.t,
    key        :: String.t
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  @spec get(
    store_name :: String.t,
    key        :: String.t
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  def get(store_name, key) do
    @engine.get(store_name, key)
  end

  @doc """
  NOTE: May be specific to ETS and not other datastores.

  """
  @callback persist(
    store_name :: String.t
  ) :: :ok | {:error, reason :: String.t}
  @spec persist(
    store_name :: String.t
  ) :: :ok | {:error, reason :: String.t}
  def persist(store_name) do
    @engine.persist(store_name)
  end

  @callback select_delete(
    store_name :: String.t,
    function   :: Function.t
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  @spec select_delete(
    store_name :: String.t,
    function   :: Function.t
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  def select_delete(store_name, function) do
    @engine.select_delete(store_name, function)
  end

  @doc """
  Saves key-value pairs to the storage service.

  """
  @callback set(
    store_name     :: String.t,
    key_value_pair :: tuple
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  @spec set(
    store_name     :: String.t,
    key_value_pair :: tuple
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  def set(store_name, key_value_pair) do
    @engine.set(store_name, key_value_pair)
  end

  @doc """
  Increments the access counter.

  """
  @callback update_counter(
    store_name :: String.t,
    key        :: String.t,
    limit      :: non_neg_integer,
    stamp      :: any
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  @spec update_counter(
    store_name :: String.t,
    key        :: String.t,
    limit      :: non_neg_integer,
    stamp      :: any
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  def update_counter(store_name, key, limit, stamp) do
    @engine.update_counter(store_name, key, limit, stamp)
  end

end

