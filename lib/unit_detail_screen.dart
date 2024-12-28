
import 'package:aqua_properties/features/nav_view/unite/unite_screen.dart';
import 'package:flutter/material.dart';

class UnitDetailScreen extends StatelessWidget {
  final String unitIdName;
  final String unitPrice;
  final String unitTotalArea;
  final String unitProjectId;


  const UnitDetailScreen({Key? key, required this.unitIdName, required this.unitPrice, required this.unitTotalArea, required this.unitProjectId, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Unit Details"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              // Image upload logic
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
               SizedBox(height: 20,),

            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                // Plan Button
                ElevatedButton(
                  onPressed: () {
                   Navigator.push(context,MaterialPageRoute(builder: (context) => UniteScreen( selectPlan: unitIdName,),));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Plan'),
                ),



                // Book Button
                ElevatedButton(
                  onPressed: () {

                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => BookingPage(unitId: unitIdName),));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Book'),
                ),

                
              ],
            ),
            SizedBox(height: 20,),
           Divider(color: Colors.black,),
           SizedBox(height: 50,),

            // Unit ID
            Row(
              children: [
                Text(
                  "Unit ID",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                 "$unitIdName",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 10),

            // Project & Address
            Row(
              children: [
                Text(
                  "Project",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  "$unitProjectId",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "Address",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  "unit.address",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 10),

            // Payment Plan, Unit Price, and Discount
            Row(
              children: [
                Text(
                  "Payment Plan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                   "N/A",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "Unit Price",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  "\$${unitPrice} (2)%",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "Discount (%)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  "${unitPrice} (2)%",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 10),

            // Total Price
            Row(
              children: [
                Text(
                  "Total Price",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  "\$${unitPrice} x 2",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Net Area & Salesperson
            Row(
              children: [
                Text(
                  "Net Area (Sq.ft)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  " $unitTotalArea",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "Salesperson",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  "unit.salesperson",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 20),

            // Image upload section
            Center(
              child: GestureDetector(
                onTap: () {
                  // Image picking logic
                },
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.blue, size: 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
