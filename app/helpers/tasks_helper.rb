module TasksHelper
  TASK_STATUS_BADGE_CLASSES = {
    "pending" => "bg-gray-100 text-gray-800",
    "in_progress" => "bg-yellow-100 text-yellow-800",
    "completed" => "bg-green-100 text-green-800"
  }.freeze

  def task_status_badge(task)
    tag.span task.status.humanize, class: [ "badge", TASK_STATUS_BADGE_CLASSES.fetch(task.status) ]
  end
end
