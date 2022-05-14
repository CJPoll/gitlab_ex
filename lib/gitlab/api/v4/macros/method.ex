defmodule Gitlab.Api.V4.Macros.Method do
  @moduledoc false
  alias Gitlab.Api.V4.Macros.Field

  defstruct [:http_method, field_names: MapSet.new(), fields: []]

  def new(http_method) do
    %__MODULE__{http_method: http_method}
  end

  def add_field!(%__MODULE__{fields: fields, field_names: field_names} = method, %Field{} = field) do
    if MapSet.member?(field_names, field.name) do
      raise "field :#{field.name} already exists for this endpoint. Check for duplicates."
    end

    field_names = MapSet.put(field_names, field.name)
    fields = [field | fields]

    fields =
      Enum.sort(fields, fn left, right ->
        left.name <= right.name
      end)

    %__MODULE__{method | field_names: field_names, fields: fields}
  end
end
