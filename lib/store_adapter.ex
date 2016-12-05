defmodule StoreAdapter do
  @moduledoc """
  Explanation here...

  """

  @doc """
  Initializes the storage service.

  """
  @callback inititalize_store(
    store_name  :: String.t,
    persistent? :: boolean
  ) :: :ok | {:error, reason :: String.t}
  @spec inititalize_store(
    store_name  :: String.t,
    persistent? :: boolean
  ) :: :ok | {:error, reason :: String.t}
  def inititalize_store(store_name, persistent?) do
  end


  @doc """
  Saves key-value pairs to the storage service.

  """
  @callback set(
    store_name :: String.t,
    {
      key   :: String.t,
      value :: non_neg_integer
    }
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  @spec set(
    store_name :: String.t,
    {
      key   :: String.t,
      value :: non_neg_integer
    }
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  def set(store_name, {key, value}) do
  end


  @doc """
  Retrieves key-value pairs from the storage service.

  """
  @callback get(
    store_name :: String.t,
    key :: String.t
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  @spec get(
    store_name :: String.t,
    key :: String.t
  ) :: {:ok, non_neg_integer} | {:error, reason :: String.t}
  def get(key) do
  end



end
