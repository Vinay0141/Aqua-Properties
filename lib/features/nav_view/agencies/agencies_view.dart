import 'package:flutter/material.dart';

class AgenciesView extends StatelessWidget {
  final String id;
  final String name;
  final String mobile;
  final String email;
  final String country;
  final String nationality;
  final String lang;
  final String units;

  const AgenciesView({
    super.key,
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.country,
    required this.nationality,
    required this.lang,
    required this.units,
  });

  Widget buildInfoCard(String label, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Agencies View',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with avatar
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Information Cards
              buildInfoCard('ID', id),
              buildInfoCard('Name', name),
              buildInfoCard('Mobile', mobile),
              buildInfoCard('Email', email),
              buildInfoCard('Country', country),
              buildInfoCard('Nationality', nationality),
              buildInfoCard('Lang', lang),
              buildInfoCard('Units', units),
            ],
          ),
        ),
      ),
    );
  }
}
