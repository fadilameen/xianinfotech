import 'package:flutter/material.dart';

class AddItemsToSale extends StatefulWidget {
  @override
  _AddItemsToSaleState createState() => _AddItemsToSaleState();
}

class _AddItemsToSaleState extends State<AddItemsToSale> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _cessController = TextEditingController();
  bool _isDiscountPercentage = true;
  bool _isTaxPercentage = true;

  double subtotal = 0.0;
  double discount = 0.0;
  double tax = 0.0;
  double cess = 0.0;
  double totalAmount = 0.0;

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    _cessController.dispose();
    super.dispose();
  }

  void _updateTotals() {
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    double price = double.tryParse(_priceController.text) ?? 0.0;
    double discountValue = double.tryParse(_discountController.text) ?? 0.0;
    double taxValue = double.tryParse(_taxController.text) ?? 0.0;
    double cessValue = double.tryParse(_cessController.text) ?? 0.0;

    setState(() {
      subtotal = quantity * price;

      // Calculate discount
      if (_isDiscountPercentage) {
        discount = (discountValue / 100) * subtotal;
      } else {
        discount = discountValue;
      }

      // Calculate tax
      if (_isTaxPercentage) {
        tax = ((taxValue / 100) * (subtotal - discount));
      } else {
        tax = taxValue;
      }

      // Cess is always an amount
      cess = cessValue;

      // Final total amount calculation
      totalAmount = subtotal - discount + tax + cess;
    });
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      // Pop and return the item data back to AddNewSales page
      Navigator.of(context).pop({
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'discount': discount,
        'tax': tax,
        'cess': cess,
        'subtotal': subtotal,
        'totalAmount': totalAmount,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Items to Sale'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _updateTotals();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                        initialValue: 'Unit',
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Rate (Price/Unit)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _updateTotals();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Discount Field
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _discountController,
                        decoration: InputDecoration(
                          labelText: 'Discount',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _updateTotals();
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    DropdownButton<bool>(
                      value: _isDiscountPercentage,
                      items: [
                        DropdownMenuItem(
                          child: Text('%'),
                          value: true,
                        ),
                        DropdownMenuItem(
                          child: Text('₹'),
                          value: false,
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _isDiscountPercentage = value!;
                          _updateTotals();
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Tax Field
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _taxController,
                        decoration: InputDecoration(
                          labelText: 'Tax',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _updateTotals();
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    DropdownButton<bool>(
                      value: _isTaxPercentage,
                      items: [
                        DropdownMenuItem(
                          child: Text('%'),
                          value: true,
                        ),
                        DropdownMenuItem(
                          child: Text('₹'),
                          value: false,
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _isTaxPercentage = value!;
                          _updateTotals();
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Cess Field
                TextFormField(
                  controller: _cessController,
                  decoration: InputDecoration(
                    labelText: 'Cess',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _updateTotals();
                  },
                ),
                SizedBox(height: 20),

                // Display Subtotal and Total Amount
                Text('Subtotal: ₹${subtotal.toStringAsFixed(2)}',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onSave,
                        child: Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
