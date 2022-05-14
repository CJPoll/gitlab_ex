defmodule Gitlab.Api.V4.Request do
  defstruct [:path, :method, url_vars: [], params: %{}]

  def new(path, method, url_vars, params \\ %{}) when is_list(url_vars) and is_map(params) do
    %__MODULE__{
      path: path,
      method: method,
      url_vars: url_vars,
      params: params
    }
  end
end
