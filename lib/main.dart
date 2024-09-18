// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xianinfotech/add_new_sales.dart';
import 'package:xianinfotech/quickicon.dart';

import 'firebase_options.dart';
import 'rounded_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void displayalertbox() {
    TextEditingController namecontroller = TextEditingController();
    TextEditingController agecontroller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New"),
          content: SizedBox(
            height: 150,
            child: Column(
              children: [
                TextField(
                  controller: namecontroller,
                  decoration: InputDecoration(hintText: "name"),
                ),
                TextField(
                  controller: agecontroller,
                  decoration: InputDecoration(hintText: "age"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("cancel"),
            ),
            TextButton(
              onPressed: () {
                String name = namecontroller.text;
                String age = agecontroller.text;

                // Ensure both fields are not empty before saving to Firestore
                if (name.isNotEmpty && age.isNotEmpty) {
                  saveDataToFirestore(name, age);
                  namecontroller.clear();
                  agecontroller.clear();
                } else {
                  print("Name and Age cannot be empty");
                }
              },
              child: Text("Submit"),
            )
          ],
        );
      },
    );
  }

  Future<void> saveDataToFirestore(String name, String age) async {
    try {
      await FirebaseFirestore.instance.collection('users').add({
        'name': name,
        'age': age,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Data added to Firestore successfully!");
    } catch (e) {
      print("Error adding data to Firestore: $e");
    }
  }

  //data retrival from firebase
  Stream<QuerySnapshot> _getDataStream() {
    return FirebaseFirestore.instance.collection('sales').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        leading: Icon(Icons.storefront_outlined),
        title: Text("xianinfotech LLP"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings_outlined),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.red.shade100),
                      foregroundColor: WidgetStateProperty.all<Color>(
                          Colors.red), // Text color
                      elevation:
                          WidgetStateProperty.all<double>(0), // Remove shadow
                      side: WidgetStateProperty.all<BorderSide>(BorderSide(
                          color: Colors.red,
                          width: 2)), // Border color and width
                      overlayColor: WidgetStateProperty.all<Color>(
                          Colors.red.shade900.withOpacity(
                              0.2)), // Transparent light red overlay for selection
                    ),
                    child: Text(
                      "Transaction Details",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.white),
                      foregroundColor: WidgetStateProperty.all<Color>(
                          Colors.grey.shade300), // Text color
                      elevation:
                          WidgetStateProperty.all<double>(0), // Remove shadow
                      side: WidgetStateProperty.all<BorderSide>(BorderSide(
                          color: Colors.grey.shade200,
                          width: 2)), // Border color and width
                      overlayColor: WidgetStateProperty.all<Color>(
                          Colors.red.shade900.withOpacity(
                              0.2)), // Transparent light red overlay for selection
                    ),
                    child: Text(
                      "Party Details",
                      style: TextStyle(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'HOME'),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined), label: 'DASHBOARD'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'ITEMS'),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_rounded), label: 'MENU'),
          BottomNavigationBarItem(
              icon: Icon(Icons.workspace_premium_outlined),
              label: 'GET PREMIUM'),
        ],
      ),
      body: Stack(children: [
        Column(
          children: [
            // Quick Links Section
            RoundedContainer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  quickLinkIcon(Icons.add_circle_outline, 'Add Txn'),
                  quickLinkIcon(Icons.bar_chart_rounded, 'Sale Report'),
                  quickLinkIcon(Icons.manage_history_rounded, 'Txn Settings'),
                  quickLinkIcon(Icons.view_list_rounded, 'Show All'),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getDataStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No data available.'));
                  }

                  // Process the documents and return a ListView
                  final documents = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final document =
                          documents[index].data() as Map<String, dynamic>;
                      final name = document['customer'] ?? 'No Name';
                      final totalAmount =
                          document['totalAmount']?.toString() ?? '0.00';
                      final balance = document['balance']?.toString() ??
                          '0.00'; // Replace with actual balance field if available
                      final timestamp =
                          (document['timestamp'] as Timestamp?)?.toDate() ??
                              DateTime.now();

                      // Format timestamp into a readable string
                      final formattedDate =
                          "${timestamp.day}-${timestamp.month}-${timestamp.year}";
                      final formattedTime =
                          "${timestamp.hour}:${timestamp.minute}";

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade200,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      "SALE",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade900,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      Text(
                                        formattedTime,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      Text(
                                        totalAmount,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    width: 18,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Balance",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      Text(
                                        balance,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                  Spacer(),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.print_outlined,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.share,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: PopupMenuButton(
                                      color: Colors.grey,
                                      itemBuilder: (context) => [],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
            bottom: 10,
            left: 100,
            right: 100,
            child: ElevatedButton(
              onPressed: () {
                // displayalertbox();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddNewSales(),
                    ));
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red, // Text color
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.currency_rupee_rounded,
                      color: Colors.white), // Rupee icon
                  SizedBox(width: 8), // Space between icon and text
                  Text("Add New Sale"),
                ],
              ),
            ))
      ]),
    );
  }
}
