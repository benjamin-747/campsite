# frozen_string_literal: true

class DropProjectMembershipsRemindable < ActiveRecord::Migration[7.0]
  def change
    remove_column(:project_memberships, :remindable, :boolean, default: true)
  end
end
