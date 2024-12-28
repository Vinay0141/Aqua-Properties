import 'package:aqua_properties/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
        actions: [
          const Text(
            "Junaid Moiden",
            style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400,color: Colors.white),
          ),
          const SizedBox(width: 20,),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              "J",
              style: TextStyle(color: Colors.lightBlue),
            ),
          ),
          const SizedBox(width: 20,),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () async {
              bool? confirmed = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Logout',style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.w700),),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          color: Colors.blueGrey[200],
                          thickness: 1,
                        ),
                        const SizedBox(height: 10,),
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
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.transparent,
                          border: Border.all(color: Colors.lightBlueAccent.shade100,width: 1.0),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('Cancel',style: TextStyle(fontSize: 16,
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.w400,),),
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.lightBlueAccent,
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Logout',style: TextStyle(fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,),),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (confirmed == true) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
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
            style: const TextStyle(fontSize: 16.0,color: Colors.lightBlue),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
