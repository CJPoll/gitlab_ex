defmodule Gitlab.Api.V4.Macros.Field do
  @moduledoc false
  defstruct [:name, :type, required: false]

  def new(name, type) do
    %__MODULE__{name: name, type: type}
  end

  def new(name, type, options) do
    required = Keyword.get(options, :required, false)
    %__MODULE__{name: name, type: type, required: required}
  end
end
