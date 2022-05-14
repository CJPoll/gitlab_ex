defmodule Gitlab.Api.V4.Users do
  import Gitlab.Api.V4.Macros

  defendpoint "/users/:user_id", :user do
    defmethod(:get)
  end
end
