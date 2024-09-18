import 'package:flutter/material.dart';

class RoundedContainer extends StatelessWidget {
  final Widget child;
  final double? height;

  const RoundedContainer({super.key, required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 3,
        top: 4,
        right: 3,
      ),
      child: Container(
        height: height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      ),
    );
  }
}
