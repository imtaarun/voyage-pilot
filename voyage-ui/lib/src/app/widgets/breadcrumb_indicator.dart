import 'package:flutter/material.dart';

class BreadcrumbIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const BreadcrumbIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: List.generate(totalSteps, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              height: 6,
              decoration: BoxDecoration(
                color: index <= currentStep ? Colors.teal : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }),
      ),
    );
  }
}