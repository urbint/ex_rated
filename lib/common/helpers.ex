defmodule ExRated.Helpers do
  @moduledoc """
  Helper functions for the Ex-Rated library.

  """

  # Returns Erlang Time as milliseconds since 00:00 GMT, January 1, 1970
  @spec timestamp() :: non_neg_integer
  def timestamp()
    case ExRated.Utils.get_otp_release() do
      ver when ver >= 18 ->
        def timestamp(), do: :erlang.system_time(:milli_seconds)

      _ ->
        def timestamp(), do: timestamp(:erlang.now())
  end

  # OTP > 18
  defp timestamp({mega, sec, micro}) do
    1000 * (mega * 1000000 + sec) + round(micro / 1000)
  end

end

