class Task < ApplicationRecord
  enum :status, { pending: 0, in_progress: 1, completed: 2 }, validate: true

  belongs_to :project

  validates :title, presence: true

  broadcasts_to ->(task) { [ task.project, "tasks-container" ] }, target: "task-list"

  after_commit :broadcast_completed_count, unless: :destroyed_by_association

  private
    def broadcast_completed_count
      broadcast_update_later_to [ project, "tasks-container" ],
        target: ActionView::RecordIdentifier.dom_id(project, "tasks-completed-count"),
        partial: "tasks/completed_count",
        locals: { project: project }
    end
end
