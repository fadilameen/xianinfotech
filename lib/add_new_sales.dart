import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart'; // Import this for date formatting
import 'package:xianinfotech/additems.dart';
import 'package:xianinfotech/main.dart';

class AddNewSales extends StatefulWidget {
  const AddNewSales({super.key});

  @override
  _AddNewSalesState createState() => _AddNewSalesState();
}

class _AddNewSalesState extends State<AddNewSales> {
  List<Map<String, dynamic>> addedItems = [];
  bool isPaymentReceived = false;
  final TextEditingController notesController = TextEditingController();
  final TextEditingController customerController = TextEditingController();
  final TextEditingController billingNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Add a GlobalKey for the form

  void _navigateToAddItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddItemsToSale()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        addedItems.add(result); // Add the returned item to the list
      });
    }
  }

  double getTotalAmount() {
    return addedItems.fold(0.0, (sum, item) => sum + item['totalAmount']);
  }

  Future<void> saveDataToFirestore({
    required String customer,
    required String billingName,
    required String phone,
    required String totalAmount,
    required String discount,
    required bool isPaymentReceived,
    required String notes,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('sales').add({
        'customer': customer,
        'billingName': billingName,
        'phone': phone,
        'totalAmount': totalAmount,
        'discount': discount,
        'isPaymentReceived': isPaymentReceived,
        'notes': notes,
        'timestamp': FieldValue.serverTimestamp(),
        'items': addedItems, // Store added items
      });
      print("Data added to Firestore successfully!");
      _showToast();
    } catch (e) {
      print("Error adding data to Firestore: $e");
    }
  }

  void _showToast() {
    Fluttertoast.showToast(
      msg: "Saved Successfully",
      toastLength: Toast
          .LENGTH_LONG, // Shows the toast for a longer duration (approx 3 seconds)
      gravity:
          ToastGravity.BOTTOM, // Displays the toast at the bottom of the screen
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDate =
        DateFormat('dd/MM/yyyy').format(DateTime.now()); // Format current date

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              children: [
                Divider(),
                Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          "Invoice No.: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("23-24-01 16"),
                      ],
                    ),
                    Spacer(),
                    Column(
                      children: [
                        Text(
                          "Date: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(currentDate), // Display the current date here
                      ],
                    )
                  ],
                ),
                SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      "Firm Name: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("xianinfotech LLP"),
                  ],
                ),
                Divider(),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Initialize the Form widget
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: customerController,
                  decoration: const InputDecoration(
                    labelText: 'Customer *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Customer cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: billingNameController,
                  decoration: const InputDecoration(
                    labelText: 'Billing Name (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (addedItems.isNotEmpty)
                  Column(
                    children: addedItems.map((item) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(
                                    'Item: ${item['quantity']} x ₹${item['price'].toStringAsFixed(2)}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Subtotal: ₹${item['subtotal'].toStringAsFixed(2)}'),
                                    Text(
                                        'Discount: ₹${item['discount'].toStringAsFixed(2)}'),
                                    Text(
                                        'Tax: ₹${item['tax'].toStringAsFixed(2)}'),
                                    Text(
                                        'Cess: ₹${item['cess'].toStringAsFixed(2)}'),
                                    Text(
                                        'Total: ₹${item['totalAmount'].toStringAsFixed(2)}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      addedItems.remove(item);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _navigateToAddItem,
                  child: const Text('Add Item'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '₹${getTotalAmount().toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: isPaymentReceived,
                      onChanged: (value) {
                        setState(() {
                          isPaymentReceived = value ?? false;
                        });
                      },
                    ),
                    const Text('Payment Received'),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  // Validate form
                  final customer = customerController.text;
                  final billingName = billingNameController.text;
                  final phone = phoneController.text;
                  final totalAmount = getTotalAmount().toStringAsFixed(2);
                  final discount =
                      "0.00"; // Replace with actual discount if applicable
                  final notes = notesController.text;

                  saveDataToFirestore(
                    customer: customer,
                    billingName: billingName,
                    phone: phone,
                    totalAmount: totalAmount,
                    discount: discount,
                    isPaymentReceived: isPaymentReceived,
                    notes: notes,
                  );
                  setState(() {
                    // Clear all TextEditingControllers
                    customerController.clear();
                    billingNameController.clear();
                    phoneController.clear();
                    notesController.clear();

                    // Clear all items
                    addedItems.clear();
                  });
                }
              },
              child: Container(
                color: Colors.blue,
                height: 50,
                child: Center(
                  child: const Text(
                    'Save & New',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  // Validate form
                  final customer = customerController.text;
                  final billingName = billingNameController.text;
                  final phone = phoneController.text;
                  final totalAmount = getTotalAmount().toStringAsFixed(2);
                  final discount =
                      "0.00"; // Replace with actual discount if applicable
                  final notes = notesController.text;

                  saveDataToFirestore(
                    customer: customer,
                    billingName: billingName,
                    phone: phone,
                    totalAmount: totalAmount,
                    discount: discount,
                    isPaymentReceived: isPaymentReceived,
                    notes: notes,
                  );
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyApp(),
                      ));
                }
              },
              child: Container(
                color: Colors.green,
                height: 50,
                child: Center(
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
