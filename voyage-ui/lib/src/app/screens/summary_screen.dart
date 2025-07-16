// summary_screen.dart

import 'package:flutter/material.dart';
import '../models/trip_models.dart'; // Import your models

class SummaryScreen extends StatefulWidget {
  final Activity activity;

  const SummaryScreen({Key? key, required this.activity}) : super(key: key);

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.activity.name);
    _descriptionController = TextEditingController(text: widget.activity.description);
    _locationController = TextEditingController(text: widget.activity.location);
    _startTimeController = TextEditingController(text: widget.activity.startTime);
    _endTimeController = TextEditingController(text: widget.activity.endTime);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // Create a new activity object with updated values
    final updatedActivity = Activity(
      name: _nameController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      activityType: widget.activity.activityType,
      alternatives: widget.activity.alternatives,
    );
    // Pop the screen and return the updated activity
    Navigator.of(context).pop(updatedActivity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Activity'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Activity Name')),
            SizedBox(height: 16),
            TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Description'), maxLines: 3),
            SizedBox(height: 16),
            TextField(controller: _locationController, decoration: InputDecoration(labelText: 'Location')),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: _startTimeController, decoration: InputDecoration(labelText: 'Start Time'))),
                SizedBox(width: 16),
                Expanded(child: TextField(controller: _endTimeController, decoration: InputDecoration(labelText: 'End Time'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}