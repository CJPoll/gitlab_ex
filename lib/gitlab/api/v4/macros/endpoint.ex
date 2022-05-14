defmodule Gitlab.Api.V4.Macros.Endpoint do
  @moduledoc false
  alias Gitlab.Api.V4.Macros.Method

  defstruct [:path, :name, methods: %{}]

  def new(path, name) do
    %__MODULE__{path: path, name: name}
  end

  def add_method!(
        %__MODULE__{methods: methods, path: path} = endpoint,
        %Method{
          http_method: http_method
        } = method
      ) do
    if methods[http_method] do
      raise "Endpoint #{inspect(path)} has already defined method #{inspect(http_method)}. Check for duplicates"
    end

    methods = Map.put(methods, http_method, method)

    %__MODULE__{endpoint | methods: methods}
  end

  def to_ast(%__MODULE__{path: path, name: name, methods: methods}, calling_module) do
    url_vars =
      path
      |> String.split("/")
      |> Enum.filter(fn segment -> String.starts_with?(segment, ":") end)
      |> Enum.map(fn var -> String.trim_leading(var, ":") end)
      |> Enum.map(&String.to_atom/1)
      |> Enum.map(fn var_name -> Macro.var(var_name, calling_module) end)

    for {http_method, method} <- methods do
      url_name = :"#{http_method}_#{name}"
      description_name = :"#{http_method}_#{name}_description"

      fields_index =
        method.fields
        |> Enum.map(fn field ->
          {field.name, field}
        end)
        |> Map.new()

      escaped_fields_index = Macro.escape(fields_index)

      quote do
        def unquote(url_name)(unquote_splicing(url_vars), params \\ %{}) when is_map(params) do
          request =
            Gitlab.Api.V4.Request.new(
              unquote(path),
              unquote(http_method),
              [unquote_splicing(url_vars)],
              params
            )

          Gitlab.Api.V4.Macros.validate(request, unquote(escaped_fields_index))
        end

        def unquote(description_name)() do
          unquote(escaped_fields_index)
        end
      end
    end
  end
end
