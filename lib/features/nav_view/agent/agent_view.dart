import 'package:aqua_properties/features/nav_view/agent/agent_details.dart';
import 'package:flutter/material.dart';

class AgentView extends StatelessWidget {
  final Customer customer;

  const AgentView({super.key, required this.customer});

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
        title: const Text("Agent View",style: TextStyle(color: Colors.white),),
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
                    customer.name != null && customer.name.isNotEmpty
                        ? customer.name![0].toUpperCase()
                        : 'N',
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
                  customer.name.toString() ?? 'No Name',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Information Cards
              buildInfoCard('ID', customer.id?.toString() ?? 'N/A'),
              buildInfoCard('Name', customer.name.toString() ?? 'N/A'),
              buildInfoCard('Mobile', customer.mobile.toString() ?? 'N/A'),
              buildInfoCard('Email', customer.email.toString() ?? 'N/A'),
              buildInfoCard('Country', customer.country.toString() ?? 'N/A'),
              buildInfoCard('Nationality', customer.nationality.toString()),
              buildInfoCard('Lang', customer.lang.toString() ?? 'N/A'),
              buildInfoCard('Units', customer.units.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
