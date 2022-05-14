defmodule Gitlab.Api.V4.Projects do
  import Gitlab.Api.V4.Macros

  # GET /projects/:id/approvals
  # POST /projects/:id/approvals

  defendpoint "/projects", :projects do
    defmethod :get do
      field(:archived, :boolean)
      field(:id_after, :positive_integer)
      field(:id_before, :positive_integer)
      field(:last_activity_after, :datetime)
      field(:last_activity_before, :datetime)
      field(:membership, :boolean)
      field(:min_access_level, :integer)
      field(:order_by, :string)
      field(:owned, :boolean)
      field(:repository_checksum_failed, :boolean)
      field(:repository_storage, :string)
      field(:search_namespaces, :boolean)
      field(:search, :string)
      field(:simple, :boolean)
      field(:sort, {:one_of, ["asc", "desc"]})
      field(:starred, :boolean)
      field(:statistics, :boolean)
      field(:topic, :string)
      field(:visibility, {:one_of, ["public", "internal", "private"]})
      field(:wiki_checksum_failed, :boolean)
      field(:with_custom_attributes, :boolean)
      field(:with_issues_enabled, :boolean)
      field(:with_merge_requests_enabled, :boolean)
      field(:with_programming_language, :string)
    end
  end

  defendpoint "/users/:user_id/projects", :user_projects do
    defmethod :get do
      field(:archived, :boolean)
      field(:id_after, :positive_integer)
      field(:id_before, :positive_integer)
      field(:membership, :boolean)
      field(:min_access_level, :integer)
      field(:order_by, :string)
      field(:owned, :boolean)
      field(:search, :string)
      field(:simple, :boolean)
      field(:sort, {:one_of, ["asc", "desc"]})
      field(:starred, :boolean)
      field(:statistics, :boolean)
      field(:visibility, {:one_of, ["public", "internal", "private"]})
      field(:with_custom_attributes, :boolean)
      field(:with_issues_enabled, :boolean)
      field(:with_merge_requests_enabled, :boolean)
      field(:with_programming_language, :string)
    end
  end

  defendpoint "/projects/:project_id", :project do
    defmethod :get do
      field(:license, :boolean)
      field(:statistics, :boolean)
      field(:with_custom_attributes, :boolean)
    end
  end
end
