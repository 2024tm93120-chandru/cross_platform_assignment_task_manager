// Forcing file re-analysis by Zapp (v3)
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
// Use relative imports for your own files
import 'add_edit_task_page.dart';
import 'auth_page.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<ParseObject> _tasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  // READ: Fetch tasks from Back4App
  Future<void> _fetchTasks() async {
    setState(() => _isLoading = true);
    final ParseUser? user = await ParseUser.currentUser();
    if (user == null) return;

    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('Task'));
    // Filter tasks by the current user
    queryBuilder.whereEqualTo('user', user);

    final response = await queryBuilder.query();

    if (response.success && response.results != null) {
      setState(() {
        _tasks = response.results as List<ParseObject>;
        _isLoading = false;
      });
    } else {
      setState(() {
        _tasks = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error?.message ?? 'Failed to fetch tasks'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // DELETE: Delete a task
  Future<void> _deleteTask(String objectId) async {
    final task = ParseObject('Task')..objectId = objectId;
    final response = await task.delete();

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchTasks(); // Refresh the list after deleting
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error?.message ?? 'Failed to delete task'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Navigate to Add/Edit page
  void _navigateToAddEditPage({ParseObject? task}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskPage(task: task),
      ),
    ).then((_) {
      // When we return from the Add/Edit page, refresh the task list
      _fetchTasks();
    });
  }

  // Handle user logout
  Future<void> _handleLogout() async {
    final user = await ParseUser.currentUser() as ParseUser;
    var response = await user.logout();

    if (response.success) {
      // Navigate back to the AuthPage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
        (Route<dynamic> route) => false, // Remove all routes from stack
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error?.message ?? 'Logout failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(
                  child: Text(
                    "No tasks found. Tap '+' to add one!",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    final title = task.get<String>('title') ?? 'No Title';
                    final description =
                        task.get<String>('description') ?? 'No Description';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(title),
                        subtitle: Text(description),
                        // UPDATE: Tap to edit
                        onTap: () => _navigateToAddEditPage(task: task),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete Task',
                          // DELETE: Button to delete
                          onPressed: () =>
                              _showDeleteConfirmation(task.objectId!),
                        ),
                      ),
                    );
                  },
                ),
      // CREATE: Floating action button to add a new task
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditPage(),
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Show a confirmation dialog before deleting
  void _showDeleteConfirmation(String objectId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task?'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTask(objectId);
              },
            ),
          ],
        );
      },
    );
  }
}
