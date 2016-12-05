defmodule ExRated.Storage do
  @moduledoc """
  Explanation here...

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

  @callback persist_and_close(state :: %{}) :: :ok | {:error, reason :: String.t}
  @spec persist_and_close(state :: %{}) :: :ok | {:error, reason :: String.t}
  def persist_and_close(state) do
    @engine.persist_and_close(state)
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
    values     :: List
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  @spec update_counter(
    store_name :: String.t,
    key        :: String.t,
    values     :: List
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  def update_counter(store_name, key, values) do
    @engine.update_counter(store_name, key, values)
  end

end


defmodule ETSStorage do

  @behaviour ExRated.Storage

  def initialize_store(store_name, false, options) do
    :ets.new(store_name, options)
  end

  def initialize_store(store_name, true, options) do
    initialize_store(store_name, false, options)

    :dets.open_file(store_name, [{:file, store_name}, {:repair, true}])
    :ets.delete_all_objects(store_name)
    :ets.from_dets(store_name, store_name)
  end

  def set(store_name, key_values) do
    :ets.insert(store_name, key_values)
  end

  def get(store_name, key) do
    :ets.lookup(store_name, key)
  end

  def persist(state) do
    %{table_name: table_name} = state
    :ets.to_dets(table_name, table_name)
  end

  def persist_and_close(state) do
    persist(state)
    :dets.close(Map.get(state, :ets_table_name))
  end

  def update_counter(store_name, key, values) do
    :ets.update_counter(store_name, key, values)
  end

  def contains(store_name, key) do
    :ets.member(store_name, key)
  end

  def select_delete(store_name, function) do
    :ets.select_delete(store_name, function)
  end

end

