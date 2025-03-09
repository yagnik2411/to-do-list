import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_task/main.dart';
import 'package:job_task/todo/model/task_model.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskManager _taskManager = TaskManager();
  String _filter = 'All';
  String _sortOption = 'A-Z';

  @override
  void initState() {
    super.initState();
    _loadTasksFromFirestore();
  }

  Future<void> _loadTasksFromFirestore() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(globalUser?.email)
            .collection('priority_tasks')
            .get();

    _taskManager.tasks.clear();
    for (var task in doc.docs) {
      _taskManager.tasks.add(
        Task(
          name: task['name'],
          priority: task['priority'],
          isCompleted: task['isCompleted'],
        ),
      );
    }
    setState(() {});
  }

  Future<void> _clearAndSaveTasksToFirestore() async {
    final userTasksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(globalUser?.email)
        .collection('priority_tasks');

    await userTasksRef.get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    for (var task in _taskManager.tasks) {
      await userTasksRef.add({
        'name': task.name,
        'priority': task.priority,
        'isCompleted': task.isCompleted,
      });
    }
  }

  Future<void> _updateFirestore() async {
    await _clearAndSaveTasksToFirestore();
  }

  void _removeTask(String taskName) {
    _taskManager.removeTask(taskName);
    _updateFirestore();
    setState(() {});
  }

  void _addTask() {
    showDialog(
      context: context,
      builder:
          (context) => TaskAddDialog(
            onTaskAdded: (name, priority) {
              _taskManager.addTask(name, priority);
              _updateFirestore();
              setState(() {});
            },
          ),
    );
  }

  void _toggleTaskCompletion(String taskName) {
    setState(() {
      _taskManager.toggleTaskCompletion(taskName);
      _updateFirestore();
    });
  }

  List<Task> _getFilteredAndSortedTasks() {
    // Apply filters
    List<Task> filteredTasks = [..._taskManager.tasks];
    if (_filter == 'Completed') {
      filteredTasks = filteredTasks.where((task) => task.isCompleted).toList();
    } else if (_filter == 'Incomplete') {
      filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case 'A-Z':
        filteredTasks.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Z-A':
        filteredTasks.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Low-High':
        filteredTasks.sort((a, b) => a.priority.compareTo(b.priority));
        break;
      case 'High-Low':
        filteredTasks.sort((a, b) => b.priority.compareTo(a.priority));
        break;
    }

    return filteredTasks;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredAndSortedTasks();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Priority Task List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.grey[800],
        centerTitle: true,
      ),
      floatingActionButton: TaskAddButton(onPressed: _addTask),
      body: Column(
        children: [
          TaskFilterBar(
            currentFilter: _filter,
            currentSortOption: _sortOption,
            onFilterChanged: (value) {
              setState(() {
                _filter = value;
              });
            },
            onSortOptionChanged: (value) {
              setState(() {
                _sortOption = value;
              });
            },
          ),
          Expanded(
            child:
                filteredTasks.isEmpty
                    ? const EmptyTasksPlaceholder()
                    : TaskListView(
                      tasks: filteredTasks,
                      onToggleCompletion: _toggleTaskCompletion,
                      onRemoveTask: _removeTask,
                    ),
          ),
        ],
      ),
    );
  }
}

class EmptyTasksPlaceholder extends StatelessWidget {
  const EmptyTasksPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 70, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new task using the + button',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class TaskAddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const TaskAddButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.grey[800],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }
}

class TaskFilterBar extends StatelessWidget {
  final String currentFilter;
  final String currentSortOption;
  final Function(String) onFilterChanged;
  final Function(String) onSortOptionChanged;

  const TaskFilterBar({
    super.key,
    required this.currentFilter,
    required this.currentSortOption,
    required this.onFilterChanged,
    required this.onSortOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.grey),
              const SizedBox(width: 8),
              FilterDropdown(
                value: currentFilter,
                items: const ['All', 'Completed', 'Incomplete'],
                onChanged: onFilterChanged,
                hint: 'Filter',
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.sort, color: Colors.grey),
              const SizedBox(width: 8),
              FilterDropdown(
                value: currentSortOption,
                items: const ['A-Z', 'Z-A', 'Low-High', 'High-Low'],
                onChanged: onSortOptionChanged,
                hint: 'Sort',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final Function(String) onChanged;
  final String hint;

  const FilterDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      hint: Text(hint),
      underline: Container(height: 0),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
      elevation: 4,
      style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500),
      items:
          items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class TaskListView extends StatelessWidget {
  final List<Task> tasks;
  final Function(String) onToggleCompletion;
  final Function(String) onRemoveTask;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.onToggleCompletion,
    required this.onRemoveTask,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            onToggleCompletion: () => onToggleCompletion(task.name),
            onRemoveTask: () => onRemoveTask(task.name),
          );
        },
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleCompletion;
  final VoidCallback onRemoveTask;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleCompletion,
    required this.onRemoveTask,
  });

  String _getPriorityText(int priority) {
    return priority == 1
        ? "Low"
        : priority == 5
        ? "Medium"
        : "High";
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 5:
        return Colors.orange;
      case 10:
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              task.isCompleted
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.transparent,
          width: 1,
        ),
      ),
      elevation: task.isCompleted ? 1 : 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: PriorityIndicator(
            priority: task.priority,
            color: priorityColor,
          ),
          title: Text(
            task.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: task.isCompleted ? Colors.grey : Colors.black87,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              fontSize: 16,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Priority: ${_getPriorityText(task.priority)}',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ),
          trailing: TaskActions(
            isCompleted: task.isCompleted,
            onToggleCompletion: onToggleCompletion,
            onRemoveTask: onRemoveTask,
          ),
        ),
      ),
    );
  }
}

class PriorityIndicator extends StatelessWidget {
  final int priority;
  final Color color;

  const PriorityIndicator({
    super.key,
    required this.priority,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class TaskActions extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onToggleCompletion;
  final VoidCallback onRemoveTask;

  const TaskActions({
    super.key,
    required this.isCompleted,
    required this.onToggleCompletion,
    required this.onRemoveTask,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          activeColor: Colors.grey[700],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          value: isCompleted,
          onChanged: (_) => onToggleCompletion(),
        ),
        Material(
          borderRadius: BorderRadius.circular(20),
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onRemoveTask,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red[400],
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TaskAddDialog extends StatefulWidget {
  final Function(String, int) onTaskAdded;

  const TaskAddDialog({super.key, required this.onTaskAdded});

  @override
  State<TaskAddDialog> createState() => _TaskAddDialogState();
}

class _TaskAddDialogState extends State<TaskAddDialog> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedPriority = 'Low';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int _getPriorityValue(String priority) {
    switch (priority) {
      case 'Low':
        return 1;
      case 'Medium':
        return 5;
      case 'High':
        return 10;
      default:
        return 1;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(_selectedPriority);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Center(
        child: Text(
          'Add New Task',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            fontSize: 20,
          ),
        ),
      ),
      content: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Task Name',
                hintText: 'Enter task name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[700]!, width: 2),
                ),
                floatingLabelStyle: TextStyle(color: Colors.grey[700]),
                prefixIcon: const Icon(Icons.task_alt),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            PrioritySelector(
              selectedPriority: _selectedPriority,
              priorityColor: priorityColor,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPriority = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Cancel', style: TextStyle(fontSize: 14)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              int priorityValue = _getPriorityValue(_selectedPriority);
              widget.onTaskAdded(_nameController.text, priorityValue);
              Navigator.pop(context);
            }
          },
          child: const Text(
            'Add Task',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      buttonPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class PrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final Color priorityColor;
  final Function(String?) onChanged;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.priorityColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Priority',
        hintText: 'Select priority level',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: priorityColor, width: 2),
        ),
        floatingLabelStyle: TextStyle(color: priorityColor),
        prefixIcon: Icon(Icons.flag, color: priorityColor),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      value: selectedPriority,
      items: [
        DropdownMenuItem(
          value: 'Low',
          child: Row(
            children: [
              const Icon(Icons.circle, size: 12, color: Colors.green),
              const SizedBox(width: 8),
              const Text('Low Priority'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'Medium',
          child: Row(
            children: [
              const Icon(Icons.circle, size: 12, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('Medium Priority'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'High',
          child: Row(
            children: [
              const Icon(Icons.circle, size: 12, color: Colors.red),
              const SizedBox(width: 8),
              const Text('High Priority'),
            ],
          ),
        ),
      ],
      onChanged: onChanged,
      icon: Icon(Icons.arrow_drop_down, color: priorityColor),
      dropdownColor: Colors.white,
      elevation: 3,
    );
  }
}
