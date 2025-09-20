import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameTextEditingController =
      TextEditingController();
  final TextEditingController phoneTextEditingController =
      TextEditingController();
  final TextEditingController emailTextEditingController =
      TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userID = currentUser.uid;

      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(userID);

      DatabaseEvent event = await userRef.once();

      if (event.snapshot.value != null) {
        Map userData = event.snapshot.value as Map;

        setState(() {
          nameTextEditingController.text = userData["name"] ?? "";
          phoneTextEditingController.text = userData["phone"] ?? "";
          emailTextEditingController.text = userData["email"] ?? "";
          isLoading = false;
        });
      } else {
        // No data found for user
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // No user logged in
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    nameTextEditingController.dispose();
    phoneTextEditingController.dispose();
    emailTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image
                  Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: const CircleAvatar(
                      child: Image(
                        image: AssetImage("assets/images/avatarman.png"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: nameTextEditingController,
                      enabled: false,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.black),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Phone
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 4,
                    ),
                    child: TextField(
                      controller: phoneTextEditingController,
                      enabled: false,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                        prefixIcon: Icon(
                          Icons.phone_android_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Email
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 4,
                    ),
                    child: TextField(
                      controller: emailTextEditingController,
                      enabled: false,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                        prefixIcon: Icon(Icons.email, color: Colors.black),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Logout button (optional)
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      // Or navigate to login screen explicitly
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 18,
                      ),
                    ),
                    child: const Text("Logout"),
                  ),
                ],
              ),
            ),
    );
  }
}
