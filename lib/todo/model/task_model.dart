class Task {
  String name;
  int priority; // Higher number means higher priority
  bool isCompleted;

  Task({required this.name, required this.priority, this.isCompleted = false});
}

class TaskManager {
  List<Task> tasks = [];

  // Add a new task to the list
  void addTask(String name, int priority) {
    tasks.add(Task(name: name, priority: priority));
  }

  // Remove a task by name
  void removeTask(String name) {
    tasks.removeWhere((task) => task.name == name);
  }

  // Get tasks sorted by priority (higher priority first)
  List<Task> getTasksByPriority() {
    List<Task> sortedTasks = List.from(tasks);
    sortedTasks.sort((a, b) => b.priority.compareTo(a.priority));
    return sortedTasks;
  }

  // Toggle task completion status
  void toggleTaskCompletion(String name) {
    for (var task in tasks) {
      if (task.name == name) {
        task.isCompleted = !task.isCompleted;
        break;
      }
    }
  }

  // Get tasks filtered by completion status
  List<Task> getFilteredTasks(bool showCompleted) {
    return tasks.where((task) => task.isCompleted == showCompleted).toList();
  }

  // Get only high-priority tasks
  List<Task> getHighPriorityTasks(int minPriority) {
    return tasks.where((task) => task.priority >= minPriority).toList();
  }
}
