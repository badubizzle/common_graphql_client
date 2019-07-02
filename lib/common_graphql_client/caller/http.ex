if Code.ensure_loaded?(HTTPoison) do
  defmodule CommonGraphQLClient.Caller.Http do
    @behaviour CommonGraphQLClient.CallerBehaviour

    @impl CommonGraphQLClient.CallerBehaviour
    def post(client, query, variables \\ [], opts \\ []) do
      body = %{
        query: query,
        variables: variables
      } |> Poison.encode!

      headers = get_headers(client, opts)
      
      case HTTPoison.post(client.http_api_url(), body, headers) do
        {:ok, %{body: json_body}} ->
          body = Poison.decode!(json_body)
          {:ok, body["data"], body["errors"]}
        {:error, error} ->
          {:error, error}
      end
    end

    def get_headers(client, opts) do
      
      headers = case client.http_api_token() do
        token when is_binary(token) ->
          [
            {"authorization", "Bearer #{client.http_api_token()}"},
            {"Content-Type", "application/json"}
          ]
        _ ->
          [{"Content-Type", "application/json"}]
      end

      case Keyword.get(opts, :headers) do
        list when is_list(list) ->
          headers ++ list
         _ ->
          headers
      end
    end

    @impl CommonGraphQLClient.CallerBehaviour
    def subscribe(_client, _subscription_name, _callback, _query, _variables \\ []) do
      raise "Not Implemented"
    end

    @impl CommonGraphQLClient.CallerBehaviour
    def supervisor(_client, _opts), do: nil
  end
end
