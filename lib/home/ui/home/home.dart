import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:job_task/editprofile/editprofile.dart';
import 'package:job_task/home/ui/sign_in/sign_in.dart';
import 'package:job_task/main.dart';
import 'package:job_task/todo/ui/task_list.dart';

// Theme colors for consistent styling
class AppTheme {
  static final Color primaryGray = Colors.grey.shade800;
  static final Color lightGray = Colors.grey.shade200;
  static final Color mediumGray = Colors.grey.shade400;
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract user details
    final String firstName = globalUser?.firstName ?? '';
    final String lastName = globalUser?.lastName ?? '';
    final String fullName = '$firstName $lastName';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryGray,
        elevation: 1,
      ),
      drawer: UserNavigationDrawer(fullName: fullName),
      body: DashboardContent(fullName: fullName),
    );
  }
}

class UserNavigationDrawer extends StatelessWidget {
  final String fullName;

  const UserNavigationDrawer({Key? key, required this.fullName})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserProfileHeader(fullName: fullName),
          NavigationOption(
            title: 'Edit Profile',
            icon: Icons.edit,
            page: const EditProfileScreen(),
          ),
          NavigationOption(
            title: 'Task List',
            icon: Icons.task_alt,
            page: const TaskScreen(),
          ),
          Divider(color: AppTheme.mediumGray),
          LogoutOption(onTap: () => AuthManager.logout(context)),
        ],
      ),
    );
  }
}

class UserProfileHeader extends StatelessWidget {
  final String fullName;

  const UserProfileHeader({Key? key, required this.fullName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(color: AppTheme.lightGray),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.grey, size: 40),
          ),
          const SizedBox(height: 10),
          Text(
            fullName,
            style: TextStyle(
              color: AppTheme.primaryGray,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget page;

  const NavigationOption({
    Key? key,
    required this.title,
    required this.icon,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGray),
      title: Text(title, style: TextStyle(color: AppTheme.primaryGray)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}

class LogoutOption extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutOption({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.logout, color: AppTheme.primaryGray),
      title: Text('Logout', style: TextStyle(color: AppTheme.primaryGray)),
      onTap: onTap,
    );
  }
}

class AuthManager {
  // Logout functionality
  static void logout(BuildContext context) async {
    // Close drawer
    Navigator.pop(context);
    await FirebaseAuth.instance.signOut();
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Logging out..."),
            ],
          ),
        );
      },
    );

    try {
      // Reset global user

      globalUser?.resetUser();
      // Navigate to login screen and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Handle any errors
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: ${e.toString()}')));
    }
  }
}

class DashboardContent extends StatelessWidget {
  final String fullName;

  const DashboardContent({Key? key, required this.fullName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            WelcomeHeader(fullName: fullName),
            const SizedBox(height: 40),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryGray,
              ),
            ),
            const SizedBox(height: 20),
            QuickActionCard(
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              icon: Icons.person,
              page: const EditProfileScreen(),
            ),
            const SizedBox(height: 16),
            QuickActionCard(
              title: 'Task List',
              subtitle: 'View and manage your tasks',
              icon: Icons.task_alt,
              page: const TaskScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeHeader extends StatelessWidget {
  final String fullName;

  const WelcomeHeader({Key? key, required this.fullName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Welcome,',
          style: TextStyle(fontSize: 16, color: AppTheme.mediumGray),
        ),
        Text(
          fullName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGray,
          ),
        ),
      ],
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;

  const QuickActionCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryGray),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryGray.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.primaryGray,
            ),
          ],
        ),
      ),
    );
  }
}
