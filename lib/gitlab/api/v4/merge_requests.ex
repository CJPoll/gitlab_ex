defmodule Gitlab.Api.V4.MergeRequests do
  import Gitlab.Api.V4.Macros

  # GET /projects/:id/merge_requests/:merge_request_iid
  defendpoint "/projects/:project_id/merge_requests/:merge_request_iid", :merge_request do
    defmethod :get do
      field(:render_html, :boolean)
      field(:include_diverged_commits_count, :boolean)
      field(:include_rebase_in_progress, :boolean)
    end
  end
end
