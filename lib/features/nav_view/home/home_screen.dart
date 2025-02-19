import 'package:aqua_properties/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool isAppInBackground = false;
  bool isLoading = true; // ✅ Added to prevent flashing dashboard

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLoginStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ Check login status before showing HomeScreen
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    bool isAppClosed = prefs.getBool('isAppClosed') ?? false;

    if (isAppClosed) {
      await prefs.setBool('isLoggedIn', false);
      await prefs.setBool('isAppClosed', false);
    }

    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      setState(() {
        isLoading = false; // ✅ Stop loading when login check is done
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      isAppInBackground = true;
    } else if (state == AppLifecycleState.resumed) {
      isAppInBackground = false;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAppClosed', false);
    } else if (state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
      _storeAppClosedFlag();
    }
  }

  Future<void> _storeAppClosedFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAppClosed', true);
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Show loading until login check completes
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        actions: [
          const Text(
            "Junaid Moiden",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white),
          ),
          const SizedBox(width: 20),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              "J",
              style: TextStyle(color: Colors.lightBlue),
            ),
          ),
          const SizedBox(width: 20),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              bool? confirmed = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      'Confirm Logout',
                      style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.w700),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(color: Colors.blueGrey[200], thickness: 1),
                        const SizedBox(height: 10),
                        const Text(
                          'Are you sure you want to logout?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16, color: Colors.lightBlueAccent, fontWeight: FontWeight.w400),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'Logout',
                          style: TextStyle(fontSize: 16, color: Colors.lightBlueAccent, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (confirmed == true) {
                await _logout();
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            child: Table(
              border: TableBorder.all(
                color: Colors.lightBlue,
                width: 1.0,
              ),
              children: [
                TableRow(
                  children: [
                    _buildTableCell(Icons.home_work, "Projects"),
                    _buildTableCell(Icons.dashboard, "My Dashboard"),
                    _buildTableCell(Icons.handshake, "EOI"),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell(Icons.book_online, "Booking"),
                    _buildTableCell(Icons.people, "Customers"),
                    _buildTableCell(Icons.business, "Agencies"),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell(Icons.calendar_month, "Logs"),
                    _buildTableCell(Icons.settings, "CRM"),
                    _buildTableCell(Icons.monetization_on, "Accounting"),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell(Icons.language, "Website"),
                    _buildTableCell(Icons.person, "Employees"),
                    _buildTableCell(Icons.more_horiz, "xxxx"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50.0, color: Colors.lightBlue),
          const SizedBox(height: 10.0),
          Text(
            title,
            style: const TextStyle(fontSize: 16.0, color: Colors.lightBlue),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ✅ Updated Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => isLoggedIn ? const HomeScreen() : const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
