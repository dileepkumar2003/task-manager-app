import 'package:flutter/material.dart';
import 'task.dart';

class AddTaskScreen extends StatefulWidget {
  final Function(Task)? onAdd; // 🔥 OPTIONAL
  final Task? task;            // 🔥 FOR EDIT

  const AddTaskScreen({super.key, this.onAdd, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String status = "To-Do";
  String priority = "Low"; // 🔥 NEW
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    // 🔥 PREFILL DATA IF EDIT MODE
    if (widget.task != null) {
      titleController.text = widget.task!.title;
      descriptionController.text = widget.task!.description;
      status = widget.task!.status;
      selectedDate = widget.task!.dueDate;
      priority = widget.task!.priority ?? "Low"; // 🔥 NEW
    }
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void saveTask() {
    if (titleController.text.isEmpty) return;

    final newTask = Task(
      title: titleController.text,
      description: descriptionController.text,
      status: status,
      dueDate: selectedDate,
      priority: priority, // 🔥 NEW
    );

    // 🔥 ADD MODE
    if (widget.onAdd != null) {
      widget.onAdd!(newTask);
      Navigator.pop(context);
    }
    // 🔥 EDIT MODE
    else {
      Navigator.pop(context, newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? "Add Task" : "Edit Task"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔥 TITLE
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            // 🔥 DESCRIPTION
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 10),

            // 🔥 STATUS DROPDOWN
            DropdownButton<String>(
              value: status,
              isExpanded: true,
              items: ["To-Do", "In Progress", "Done"]
                  .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
            ),

            const SizedBox(height: 10),

            // 🔥 PRIORITY DROPDOWN (STEP 2 ADDED)
            DropdownButtonFormField<String>(
              value: priority,
              items: ["High", "Medium", "Low"]
                  .map((p) => DropdownMenuItem(
                value: p,
                child: Text(p),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() => priority = value!);
              },
              decoration: const InputDecoration(
                labelText: "Priority",
              ),
            ),

            const SizedBox(height: 10),

            // 🔥 DATE PICKER
            ElevatedButton(
              onPressed: pickDate,
              child: Text(
                "Pick Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 SAVE BUTTON
            ElevatedButton(
              onPressed: saveTask,
              child: Text(widget.task == null ? "Save Task" : "Update Task"),
            ),
          ],
        ),
      ),
    );
  }
}