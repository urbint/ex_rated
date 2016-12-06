defmodule ExRated do
  use GenServer

  @moduledoc """
    An Elixir OTP GenServer that provides the ability to manage rate limiting
    for any process that needs it.  This rate limiter is based on the
    concept of a 'token bucket'.  You can read more here:

      http://en.wikipedia.org/wiki/Token_bucket

    This application started as a direct port of the Erlang 'raterlimiter' project
    created by Alexander Sorokin (https://github.com/Gromina/raterlimiter,
    gromina@gmail.com, http://alexsorokin.ru) and the primary credit for
    the functionality goes to him. This has been implemented in Elixir
    as a learning experiment and I hope you find it useful. Pull requests are
    welcome.
  """

  alias ExRated.Storage

  ## Client API

  @doc """
  Starts the ExRated rate limit counter server.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__,
                        [
                           {:timeout,         Application.get_env(:ex_rated, :timeout) || 90_000_000},
                           {:cleanup_rate,    Application.get_env(:ex_rated, :cleanup_rate) || 60_000},
                           {:table_name,      Application.get_env(:ex_rated, :table_name) || :ex_rated_buckets},
                           {:storage_config,  Application.get_env(:ex_rated, :storage_config) || %{}},
                           {:persistent,      Application.get_env(:ex_rated, :persistent) || false},
                        ], opts)
  end

  @doc """
  Check if the action you wish to take is within the rate limit bounds
  and increment the buckets counter by 1 and its updated_at timestamp.

  ## Arguments:

  - `id` (String) name of the bucket
  - `scale` (Integer) of time in ms until the bucket rolls over. (e.g. 60_000 = empty bucket every minute)
  - `limit` (Integer) the max size of a counter the bucket can hold.

  ## Examples

      # Limit to 2500 API requests in one day.
      iex> ExRated.check_rate("my-bucket", 86400000, 2500)
      {:ok, 1}

  """
  @spec check_rate(id::String.t, scale::integer, limit::integer) :: {:ok, count::integer} | {:error, limit::integer}
  def check_rate(id, scale, limit) do
    GenServer.call(:ex_rated, {:check_rate, id, scale, limit})
  end

  @doc """
  Inspect bucket to get count, count_remaining, ms_to_next_bucket, created_at, updated_at.
  This function is free of side-effects and should be called with the same arguments you
  would use for `check_rate` if you intended to increment and check the bucket counter.

  ## Arguments:

  - `id` (String) name of the bucket
  - `scale` (Integer) of time the bucket you want to inspect was created with.
  - `limit` (Integer) representing the max counter size the bucket was created with.

  ## Example - Reset counter for my-bucket

      ExRated.inspect_bucket("my-bucket", 86400000, 2500)
      {0, 2500, 29389699, nil, nil}
      ExRated.check_rate("my-bucket", 86400000, 2500)
      {:ok, 1}
      ExRated.inspect_bucket("my-bucket", 86400000, 2500)
      {1, 2499, 29381612, 1450281014468, 1450281014468}

  """
  @spec inspect_bucket(id::String.t, scale::integer, limit::integer) :: {count::integer,
                                                                         count_remaining::integer,
                                                                         ms_to_next_bucket::integer,
                                                                         created_at :: integer | nil,
                                                                         updated_at :: integer | nil}
  def inspect_bucket(id, scale, limit) do
    GenServer.call(:ex_rated, {:inspect_bucket, id, scale, limit})
  end

  @doc """
  Delete bucket to reset the counter.

  ## Arguments:

  - `id` (String) name of the bucket

  ## Example - Reset counter for my-bucket

      iex> ExRated.check_rate("my-bucket", 86400000, 2500)
      {:ok, 1}
      iex> ExRated.delete_bucket("my-bucket")
      :ok

  """
  @spec delete_bucket(id::String.t) :: :ok | :error
  def delete_bucket(id) do
    GenServer.call(:ex_rated, {:delete_bucket, id})
  end

  @doc """
  Stop the rate limit counter server.
  """
  def stop(server) do
    GenServer.call(server, :stop)
  end

  ## Server Callbacks

  def init(args) do
    [
      {:timeout, timeout},
      {:cleanup_rate, cleanup_rate},
      {:table_name, table_name},
      {:storage_config, storage_config},
      {:persistent, persistent}
    ] = args

    open_table(table_name, persistent, storage_config)
    :timer.send_interval(cleanup_rate, :prune)
    {:ok, %{
      timeout: timeout,
      cleanup_rate: cleanup_rate,
      table_name: table_name,
      persistent: persistent
    }}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_call({:check_rate, id, scale, limit}, _from, state) do
    %{table_name: table_name} = state
    result = count_hit(id, scale, limit, table_name)
    {:reply, result, state}
  end

  def handle_call({:inspect_bucket, id, scale, limit}, _from, state) do
    %{table_name: table_name} = state
    result = inspect_bucket(id, scale, limit, table_name)
    {:reply, result, state}
  end

  def handle_call({:delete_bucket, id}, _from, state) do
    %{table_name: table_name} = state
    result = delete_bucket(id, table_name)
    {:reply, result, state}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:reply, state}
  end

  def handle_info(:prune, state) do
    %{timeout: timeout, table_name: table_name} = state
    Storage.prune_expired_buckets(table_name, timeout)

    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def terminate(_reason, state) do
    %{table_name: table_name} = state
    # if persistent is true save ETS table on disk and then close DETS table
    if persistent?(state), do: persist_and_close(table_name)

    :ok
  end

  def code_change(_old_version, state, _extra) do
    {:ok, state}
  end


  ## Private Functions

  defp open_table(table_name, persistent?, storage_config) do
    Storage.initialize_store(table_name, persistent?, storage_config)
  end

  defp persistent?(state) do
    Map.get(state, :persistent) == true
  end

  defp persist_and_close(table_name) do
    Storage.persist(table_name)
    Storage.close(table_name)
  end

  defp count_hit(id, scale, limit, table_name) do
    {stamp, key} = stamp_key(id, scale)

    Storage.update_counter(table_name, key, limit, stamp)
  end

  defp inspect_bucket(id, scale, limit, table_name) do
    {stamp, key} = stamp_key(id, scale)
    ms_to_next_bucket = (elem(key, 0) * scale) + scale - stamp

    case Storage.contains(table_name, key) do
      false ->
        {0, limit, ms_to_next_bucket, nil, nil}

      true ->
        [{_, count, created_at, updated_at}] = Storage.get(table_name, key)
        count_remaining = if limit > count, do: limit - count, else: 0
        {count, count_remaining, ms_to_next_bucket, created_at, updated_at}
    end
  end

  defp delete_bucket(id, table_name) do
    import Ex2ms

    case Storage.delete_bucket_by_id(table_name, id) do
      1 ->
        :ok

      _ ->
        :error
    end
  end

  defp stamp_key(id, scale) do
    alias ExRated.Helpers

    stamp         = Helpers.timestamp()
    bucket_number = trunc(stamp / scale) # with scale = 1 bucket changes every millisecond
    key           = {bucket_number, id}

    {stamp, key}
  end

end
