defmodule Gitlab.Api.V4.MergeRequestApprovals do
  import Gitlab.Api.V4.Macros

  defendpoint "/projects/:project_id/approvals", :approvals do
    defmethod(:get)

    defmethod :post do
      field(:approvals_before_merge, [:integer, nil])
      field(:reset_approvals_on_push, :boolean)
      field(:disable_overriding_approvers_per_merge_request, :boolean)
      field(:merge_requests_author_approval, :boolean)
      field(:merge_requests_disable_committers_approval, :boolean)
      field(:require_password_to_approve, :boolean)
    end
  end

  defendpoint "/projects/:project_id/approval_rules", :approval_rules do
    defmethod(:get)
  end

  defendpoint "/projects/:project_id/approval_rules/:approval_rule_id", :approval_rule do
    defmethod(:get)

    defmethod :post do
      field(:name, :string, required: true)
      field(:approvals_required, :integer, required: true)
      field(:rule_type, :string)
      field(:user_ids, {:array, :integer})
      field(:group_ids, {:array, :integer})
      field(:protected_branch_ids, {:array, :integer})
    end
  end

  defendpoint "/projects/:project_id/merge_requests/:merge_request_iid/approvals",
              :merge_request_level_approvals do
    defmethod(:get)
  end

  defendpoint "/projects/:project_id/merge_requests/:merge_request_iid/approval_state",
              :merge_request_level_approval_state do
    defmethod(:get)
  end
end
