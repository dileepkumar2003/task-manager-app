import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final nameController = TextEditingController();

  File? imageFile;
  String? imagePath;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController.text = user?.displayName ?? "User";
    loadProfile();
  }

  // ✅ LOAD FROM FIRESTORE
  Future<void> loadProfile() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      setState(() {
        imagePath = doc['image']; // LOCAL PATH
        nameController.text = doc['name'] ?? "";
      });
    }
  }

  // ✅ PICK IMAGE (LOCAL ONLY)
  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
        imagePath = picked.path;
      });

      await saveProfile(); // SAVE PATH
    }
  }

  // ✅ SAVE PROFILE (NO STORAGE)
  Future<void> saveProfile() async {
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .set({
      "name": nameController.text,
      "image": imagePath,
    }, SetOptions(merge: true));
  }

  // ✅ UPDATE NAME
  Future<void> updateName() async {
    await saveProfile();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated")),
    );
  }

  // ✅ LOGOUT POPUP
  void confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  // ✅ IMAGE PICK OPTIONS
  void showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text("Camera"),
            onTap: () {
              Navigator.pop(context);
              pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text("Gallery"),
            onTap: () {
              Navigator.pop(context);
              pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ✅ AVATAR (LOCAL IMAGE)
            GestureDetector(
              onTap: showImagePickerOptions,
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blue,
                backgroundImage: imageFile != null
                    ? FileImage(imageFile!)
                    : (imagePath != null
                    ? FileImage(File(imagePath!))
                    : null),
                child: (imageFile == null && imagePath == null)
                    ? const Icon(Icons.person,
                    size: 50, color: Colors.white)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Name"),
            ),

            const SizedBox(height: 10),

            Text(
              user?.email ?? "",
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: updateName,
              child: const Text("Update Profile"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red),
              onPressed: confirmLogout,
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}