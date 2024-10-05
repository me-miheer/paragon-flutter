import 'package:flutter/material.dart';

class CustomLoader extends StatelessWidget {
  final bool isLoading;

  const CustomLoader({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
      color: Colors.black54, // Semi-transparent background
      child: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    )
        : Container(); // Return an empty container if not loading
  }
}
