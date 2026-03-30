import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showMessage("Enter email & password");
      return;
    }

    try {
      setState(() => isLoading = true);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // ✅ No navigation needed (StreamBuilder handles it)

    } on FirebaseAuthException catch (e) {
      String message = "Login failed";

      if (e.code == 'user-not-found') {
        message = "User not found";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email";
      } else if (e.code == 'invalid-credential') {
        message = "Invalid credentials";
      }

      showMessage(message);
    } catch (e) {
      showMessage("Something went wrong");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> signup() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showMessage("Enter email & password");
      return;
    }

    try {
      setState(() => isLoading = true);

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      showMessage("Account created successfully 🎉");

    } on FirebaseAuthException catch (e) {
      String message = "Signup failed";

      if (e.code == 'email-already-in-use') {
        message = "Email already registered";
      } else if (e.code == 'weak-password') {
        message = "Password too weak";
      }

      showMessage(message);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text("Login")),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔥 EMAIL
                TextField(
                  controller: emailController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),

                const SizedBox(height: 15),

                // 🔥 PASSWORD
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // 🔥 BUTTONS
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        child: const Text("Login"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: isLoading ? null : signup,
                        child: const Text("Create Account"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 🔥 FULL SCREEN LOADER
        if (isLoading)
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