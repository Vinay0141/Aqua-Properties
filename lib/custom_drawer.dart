import 'package:flutter/material.dart';


class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Container(
          color: Colors.lightBlue, // Background color of the drawer
          child: Column(
            children: [
              // Header section
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.white,
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://www.constructionweekonline.com/cloud/2023/12/05/aqua8.jpg',), // Replace with actual background image
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                          'https://via.placeholder.com/150'), // Replace with profile picture URL
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Junaid Areeparambil",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
             
      
              // Menu items
              Expanded(
                child: ListView(
                  children: [
                    _buildDrawerItemWithDivider(Icons.home, "Home"),
                    _buildDrawerItemWithDivider(Icons.apartment, "Projects"),
                    _buildDrawerItemWithDivider(
                        Icons.real_estate_agent, "Property"),
                    _buildDrawerItemWithDivider(Icons.settings, "CRM"),
                    _buildDrawerItemWithDividerWithBadge(
                        Icons.book_online, "Booking", "5"),
                    _buildDrawerItemWithDivider(Icons.support_agent, "Support"),
                  ],
                ),
              ),
              const Divider(color: Colors.white),
              // Footer
              _buildDrawerItem(Icons.logout, "Sign Out"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItemWithDivider(IconData icon, String title) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () {},
        ),
        const Divider(color: Colors.white, height: 1),
      ],
    );
  }

  Widget _buildDrawerItemWithDividerWithBadge(
      IconData icon, String title, String badgeCount) {
    return Column(
      children: [
        ListTile(
          leading: Stack(
            children: [
              Icon(icon, color: Colors.white),
              Positioned(
                right: 0,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    badgeCount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () {},
        ),
        const Divider(color: Colors.white, height: 1),
      ],
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {},
    );
  }
}