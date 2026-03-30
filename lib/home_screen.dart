import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_task_screen.dart';
import 'task.dart';
import 'notifications.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'chart_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;

  const HomeScreen({super.key, required this.toggleTheme, required this.isDark});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;
  bool isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> addTaskToCloud(Task task) async {
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("tasks")
        .add(task.toJson());

    showNotification();
  }

  Future<void> logout() async {
    setState(() => isLoggingOut = true);

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logout failed")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoggingOut = false);
      }
    }
  }

  // 🔥 UPDATED: EDIT FEATURE ADDED
  Widget buildTaskCard(Task task, String docId) {
    Color color;

    switch (task.priority) {
      case "High":
        color = Colors.red;
        break;
      case "Medium":
        color = Colors.orange;
        break;
      default:
        color = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(task.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description),
            const SizedBox(height: 5),
            Text(
              "Priority: ${task.priority}",
              style: TextStyle(color: color),
            ),
          ],
        ),

        // 🔥 STEP 4 EDIT BUTTON
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: color, size: 12),

            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                final updatedTask = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTaskScreen(task: task),
                  ),
                );

                if (updatedTask != null) {
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(user!.uid)
                      .collection("tasks")
                      .doc(docId)
                      .update(updatedTask.toJson());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Dashboard"),
            actions: [
              IconButton(
                icon: const Icon(Icons.dark_mode),
                onPressed: widget.toggleTheme,
              ),

              // 🔥 STEP 6: PROFILE BUTTON ADDED
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),

              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: logout,
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(
                        isDark: widget.isDark,
                        onThemeChange: (val) {
                          widget.toggleTheme();
                        },
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.bar_chart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChartScreen()),
                  );
                },
              ),
            ],
          ),

          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(user?.uid ?? "no_user")
                .collection("tasks")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = snapshot.data?.docs ?? [];

              if (tasks.isEmpty) {
                return const Center(child: Text("No tasks yet 🚀"));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Welcome 👋",
                      style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Your Tasks",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = Task.fromJson(
                            tasks[index].data() as Map<String, dynamic>);

                        final docId = tasks[index].id;

                        return Dismissible(
                          key: Key(docId),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete,
                                color: Colors.white),
                          ),
                          onDismissed: (_) async {
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(user!.uid)
                                .collection("tasks")
                                .doc(docId)
                                .delete();
                          },
                          child: buildTaskCard(task, docId), // 🔥 UPDATED
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskScreen(
                    onAdd: (task) {
                      addTaskToCloud(task);
                    },
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),

        if (isLoggingOut)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
