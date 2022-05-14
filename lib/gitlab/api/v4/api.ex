defmodule Gitlab.Api.V4.Api do
  use HTTPoison.Base

  alias Gitlab.Api.V4.Request

  def uri(%Request{} = request) do
    base_url =
      :gitlab_ex
      |> Application.get_env(:v4_base_url, "https://gitlab.com/api/v4/")
      |> String.trim_trailing("/")

    path = with_url_vars!(request.path, request.url_vars)

    uri =
      [base_url, path]
      |> Path.join()
      |> URI.parse()

    add_params(request, uri)
    |> IO.inspect(label: "GITLAB URL")
  end

  defp add_params(%Request{method: :get, params: params}, %URI{} = uri) do
    %URI{uri | query: URI.encode_query(params)}
  end

  defp add_params(%Request{}, %URI{} = uri), do: uri

  def process_request_options(options) do
    proxy = Application.get_env(:gitlab_ex, :proxy, nil)

    case proxy do
      "" ->
        options

      nil ->
        options

      proxy ->
        uri = URI.parse(proxy)

        options
        |> Keyword.put(:proxy, {:socks5, uri.host |> String.to_charlist(), uri.port})

        # |> Keyword.put(:hackney, pool: false)
    end
    |> IO.inspect(label: "REQUEST_OPTIONS")
  end

  def call(%Request{} = request) do
    url =
      request
      |> uri()
      |> URI.to_string()
      |> String.to_charlist()

    body =
      case request.method do
        :get -> ""
        _other -> request.params
      end

    token = Application.get_env(:gitlab_ex, :token, "")

    headers = [{"Authorization", "Bearer " <> token}]

    # %{method: request.method, url: url, body: body, headers: headers}
    request(request.method, url |> IO.inspect(label: "URL Passed to hackney"), body, headers)
  end

  def process_request_body(params) when is_binary(params) do
    params
  end

  def process_request_body(params) when is_map(params) do
    Jason.encode!(params)
  end

  def process_response_body(body) do
    Jason.decode!(body)
  end

  def with_url_vars!(path, []), do: path

  def with_url_vars!(path, url_vars) do
    {reversed_segments, []} =
      path
      |> Path.split()
      |> Enum.reduce({[], url_vars}, fn
        ":" <> _segment, {processed_segments, [var | url_vars]} ->
          var =
            if is_binary(var) do
              String.replace(var, "/", "%2F")
            else
              inspect(var)
            end

          {[var | processed_segments], url_vars}

        segment, {processed_segments, url_vars} ->
          {[segment | processed_segments], url_vars}
      end)

    reversed_segments
    |> Enum.reverse()
    |> Path.join()
  end
end
