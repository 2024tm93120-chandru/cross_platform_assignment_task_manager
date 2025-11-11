// Forcing file re-analysis by Zapp (v3)
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AddEditTaskPage extends StatefulWidget {
  final ParseObject? task;

  const AddEditTaskPage({Key? key, this.task}) : super(key: key);

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    // If we are editing, pre-fill the form fields
    if (_isEditing) {
      _titleController.text = widget.task!.get<String>('title') ?? '';
      _descriptionController.text =
          widget.task!.get<String>('description') ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Handle saving the task (Create or Update)
  Future<void> _handleSave() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title cannot be empty'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final ParseUser? user = await ParseUser.currentUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User not found. Please log in again.'),
            backgroundColor: Colors.redAccent),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Determine if we are creating or updating
    final taskToSave = _isEditing ? widget.task! : ParseObject('Task');

    // Link the task to the current user
    if (!_isEditing) {
      taskToSave.set('user', user);
    }

    taskToSave
      ..set('title', _titleController.text.trim())
      ..set('description', _descriptionController.text.trim());

    final response = await taskToSave.save();

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Task updated!' : 'Task created!'),
          backgroundColor: Colors.green,
        ),
      );
      // Go back to the previous screen (Task List)
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error?.message ?? 'Failed to save task'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  // FIX: Changed BuildContextg to BuildContext
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Add Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            // Description Field
            TextField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),
            // Save Button
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save Task'),
                  ),
          ],
        ),
      ),
    );
  }
}
