defmodule Gitlab.Api.V4.Macros do
  alias Gitlab.Api.V4.Macros.{Endpoint, Field, Method}

  def validate(request, fields_index) do
    validate_allowed!(request, fields_index)
    validate_required!(request, fields_index)
    validate_types!(request, fields_index)

    request
  end

  defmacro defendpoint(path, name) do
    quote do
      unquote(__MODULE__).defendpoint unquote(path), unquote(name) do
        # This space intentionally left blank
      end
    end
  end

  defmacro defendpoint(path, name, do: block) do
    endpoint = Endpoint.new(path, name)

    {_ast, endpoint} =
      Macro.prewalk(block, endpoint, fn
        {:defmethod, _, [http_method]}, endpoint ->
          method = Method.new(http_method)
          endpoint = Endpoint.add_method!(endpoint, method)
          {nil, endpoint}

        {:defmethod, _, [http_method, [do: method_block]]}, endpoint ->
          method = Method.new(http_method)

          {_ast, method} =
            Macro.prewalk(method_block, method, fn
              {:field, _, [name, type]}, method ->
                field = Field.new(name, type)
                method = Method.add_field!(method, field)
                {nil, method}

              {:field, _, [name, type, options]}, method ->
                field = Field.new(name, type, options)
                method = Method.add_field!(method, field)
                {nil, method}

              ast, method ->
                {ast, method}
            end)

          endpoint = Endpoint.add_method!(endpoint, method)

          {nil, endpoint}

        ast, endpoint ->
          {ast, endpoint}
      end)

    Endpoint.to_ast(endpoint, __CALLER__.module)
  end

  defmacro defmethod(http_method) do
    {:defmethod, [], [http_method]}
  end

  defmacro defmethod(http_method, do: block) do
    {:defmethod, [], [http_method, do: block]}
  end

  defp validate_required!(request, fields_index) do
    case missing_required_field_names(request, fields_index) do
      [] ->
        :ok

      missing_names when is_list(missing_names) ->
        raise "Missing required fields: #{inspect(missing_names)}"
    end
  end

  defp validate_types!(request, fields_index) do
    request.params
    |> Enum.each(fn {name, value} ->
      expected_type = fields_index[name].type

      if valid_type?(value, expected_type) do
        :ok
      else
        raise "field #{inspect(name)} must be a #{inspect(expected_type)}. Got: #{inspect(value)}"
      end
    end)
  end

  defp valid_type?(value, union) when is_list(union) do
    Enum.any?(union, fn type ->
      valid_type?(value, type)
    end)
  end

  defp valid_type?(list, {:array, type}) when is_list(list) do
    Enum.all?(list, fn value ->
      valid_type?(value, type)
    end)
  end

  defp valid_type?(value, :integer) when is_integer(value), do: true
  defp valid_type?(value, :boolean) when is_boolean(value), do: true
  defp valid_type?(value, :string) when is_binary(value), do: String.valid?(value)
  defp valid_type?(value, :binary) when is_binary(value), do: true
  defp valid_type?(value, :positive_integer) when is_integer(value) and value > 0, do: true
  defp valid_type?(value, nil) when is_nil(value), do: true

  defp valid_type?(value, {:one_of, values}) when is_list(values) do
    Enum.any?(values, &(&1 == value))
  end

  defp valid_type?(value, :natural_integer) when is_integer(value) and value >= 0, do: true
  defp valid_type?(value, :negative_integer) when is_integer(value) and value < 0, do: true
  defp valid_type?(%DateTime{}, :datetime), do: true
  defp valid_type?(%NaiveDateTime{}, :datetime), do: true
  # If you pass a date in as a string, we're not going to verify its
  # correctness; that's gitlab's job.
  defp valid_type?(value, :datetime) when is_binary(value), do: true
  defp valid_type?(_value, _type), do: false

  defp has_field?(request, field_name) when is_atom(field_name) do
    Map.has_key?(request.params, field_name) ||
      Map.has_key?(request.params, Atom.to_string(field_name))
  end

  defp missing_required_field_names(request, fields_index) do
    fields_index
    |> Map.values()
    |> Enum.filter(& &1.required)
    |> Enum.reject(&has_field?(request, &1.name))
    |> Enum.map(& &1.name)
  end

  defp validate_allowed!(request, fields_index) do
    allowed_field_names =
      fields_index
      |> Map.keys()
      |> MapSet.new()

    allowed_field_names_strings =
      fields_index
      |> Map.keys()
      |> Enum.map(&Atom.to_string/1)
      |> MapSet.new()

    submitted_fields =
      request.params
      |> Map.keys()
      |> MapSet.new()

    unless MapSet.subset?(submitted_fields, allowed_field_names) or
             MapSet.subset?(submitted_fields, allowed_field_names_strings) do
      unaccepted_fields =
        if submitted_fields |> Enum.random() |> is_atom() do
          submitted_fields
          |> MapSet.difference(allowed_field_names)
          |> MapSet.to_list()
        else
          submitted_fields
          |> MapSet.difference(allowed_field_names_strings)
          |> MapSet.to_list()
        end

      raise "Invalid parameters submitted: #{inspect(unaccepted_fields)}"
    end

    :ok
  end
end
