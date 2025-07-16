import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TripPlanningScreen extends StatefulWidget {
  const TripPlanningScreen({super.key});

  @override
  State<TripPlanningScreen> createState() => _TripPlanningScreenState();
}

class _TripPlanningScreenState extends State<TripPlanningScreen> {
  final _formKey = GlobalKey<FormState>();

  // Main Trip Details Controllers
  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _tripDescriptionController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  // AI Generation Dialog Controllers
  final TextEditingController _aiStartLocationController = TextEditingController();
  final TextEditingController _aiDestinationController = TextEditingController();
  bool _aiIncludeFood = false;
  final TextEditingController _aiCustomDescriptionController = TextEditingController();

  // Trip Itinerary Data (Directly mapping to JSON structure)
  List<Map<String, dynamic>> _currentTripDays = [];

  // Controllers for notes per day (managed dynamically)
  Map<int, TextEditingController> _notesControllers = {};

  // Loading state for AI generation dialog
  bool _isGeneratingTrip = false;

  @override
  void initState() {
    super.initState();
    _initializeEmptyTrip();
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    _tripDescriptionController.dispose();
    _aiStartLocationController.dispose();
    _aiDestinationController.dispose();
    _aiCustomDescriptionController.dispose();
    _notesControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  // Helper to initialize/reset trip day structure based on selected date range
  void _initializeTripDaysStructure() {
    developer.log('--- Initializing Trip Days Structure ---');
    developer.log('Selected Date Range for init: $_selectedDateRange');

    _notesControllers.forEach((key, controller) => controller.dispose());
    _notesControllers.clear();

    _currentTripDays.clear(); // Clear existing days

    if (_selectedDateRange != null) {
      DateTime currentDate = _selectedDateRange!.start;
      int dayIndex = 0;
      while (!currentDate.isAfter(_selectedDateRange!.end)) {
        _currentTripDays.add({
          "date": DateFormat('yyyy-MM-dd').format(currentDate),
          "notes": "",
          "activities": <Map<String, dynamic>>[], // Explicitly type the list
        });
        _notesControllers[dayIndex] = TextEditingController();
        developer.log('  Created note controller for day $dayIndex: ${DateFormat('yyyy-MM-dd').format(currentDate)}');
        currentDate = currentDate.add(const Duration(days: 1));
        dayIndex++;
      }
    }
    developer.log('Current Trip Days count after init: ${_currentTripDays.length}');
  }

  void _initializeEmptyTrip() {
    _tripNameController.text = "";
    _tripDescriptionController.text = "";
    _selectedDateRange = null;
    _initializeTripDaysStructure();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _initializeTripDaysStructure(); // Re-initialize structure for new dates
      });
    }
  }

  void _saveTripToJson() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDateRange == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select trip dates.")),
        );
        return;
      }

      // Update notes in _currentTripDays from controllers before saving
      for (int i = 0; i < _currentTripDays.length; i++) {
        if (_notesControllers.containsKey(i)) {
          _currentTripDays[i]['notes'] = _notesControllers[i]!.text.trim();
        }
      }

      final Map<String, dynamic> tripJson = {
        "trip": {
          "name": _tripNameController.text.trim(),
          "description": _tripDescriptionController.text.trim(),
          "startDate": DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start),
          "endDate": DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end),
        },
        "tripDays": _currentTripDays,
      };

      developer.log('Generated JSON for Backend: ${jsonEncode(tripJson)}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Trip JSON generated (check console)! In a real app, this would be saved.")),
      );
    }
  }

  Future<void> _showGenerateTripDialog() async {
    DateTimeRange? dialogSelectedDateRange = _selectedDateRange;
    final GlobalKey<FormState> aiFormKey = GlobalKey<FormState>();
    bool tempAiIncludeFood = _aiIncludeFood;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Generate Trip with AI"),
              content: SingleChildScrollView(
                child: Form(
                  key: aiFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _aiStartLocationController,
                        decoration: const InputDecoration(
                          labelText: "Start Location",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) => value!.isEmpty ? "Enter start location" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _aiDestinationController,
                        decoration: const InputDecoration(
                          labelText: "Destination",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (value) => value!.isEmpty ? "Enter destination" : null,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text(dialogSelectedDateRange == null
                            ? 'Select Trip Dates'
                            : 'From: ${DateFormat('yyyy-MM-dd').format(dialogSelectedDateRange!.start)} → To: ${DateFormat('yyyy-MM-dd').format(dialogSelectedDateRange!.end)}'),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(now.year - 1),
                            lastDate: DateTime(now.year + 5),
                            initialDateRange: dialogSelectedDateRange,
                          );
                          if (picked != null && picked != dialogSelectedDateRange) {
                            setDialogState(() {
                              dialogSelectedDateRange = picked;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text("Include food options"),
                        value: tempAiIncludeFood,
                        onChanged: (val) {
                          setDialogState(() {
                            tempAiIncludeFood = val ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _aiCustomDescriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Custom preferences (e.g., 'family-friendly', 'historical sites')",
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isGeneratingTrip ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: _isGeneratingTrip
                      ? null
                      : () async {
                    if (aiFormKey.currentState!.validate() && dialogSelectedDateRange != null) {
                      setDialogState(() {
                        _isGeneratingTrip = true;
                      });
                      try {
                        _aiIncludeFood = tempAiIncludeFood;
                        await _callAIGenerationBackend(dialogSelectedDateRange!);
                        if (!mounted) return;
                        Navigator.of(dialogContext).pop();
                      } catch (e) {
                        developer.log("Error in AI generation dialog action: $e");
                      } finally {
                        if (mounted) {
                          setDialogState(() {
                            _isGeneratingTrip = false;
                          });
                        }
                      }
                    } else {
                      if (dialogSelectedDateRange == null) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text("Please select trip dates for AI generation.")),
                        );
                      }
                    }
                  },
                  child: _isGeneratingTrip
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text("Generate"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _callAIGenerationBackend(DateTimeRange aiDateRange) async {
    final requestPayload = {
      'start_location': _aiStartLocationController.text.trim(),
      'destination': _aiDestinationController.text.trim(),
      'start_date': aiDateRange.start.toIso8601String(),
      'end_date': aiDateRange.end.toIso8601String(),
      'include_food': _aiIncludeFood,
      'description': _aiCustomDescriptionController.text.trim(),
    };

    final url = Uri.parse('http://10.0.2.2:3000/trips/generate');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> generatedData = jsonDecode(response.body);
        developer.log('AI Generated Trip Data RECEIVED: ${jsonEncode(generatedData)}'); // VERIFY THIS OUTPUT
        _populateManualFormWithAIData(generatedData);
      } else {
        developer.log('AI generation failed: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to generate trip: ${response.body}")),
        );
      }
    } catch (e) {
      developer.log('Error calling AI generation backend: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error connecting to AI service: $e")),
      );
    }
  }

  void _populateManualFormWithAIData(Map<String, dynamic> generatedJson) {
    developer.log('*** Populating form with AI data ***'); // Debug log

    setState(() {
      final Map<String, dynamic> tripHeader = (generatedJson['tripPlan']['trip'] as Map<String, dynamic>?) ?? {};
      final List<dynamic> generatedTripDaysRaw = (generatedJson['tripPlan']['tripDays'] as List<dynamic>?) ?? [];

      developer.log('Generated tripHeader: $tripHeader'); // Debug log
      developer.log('Generated tripDaysRaw count: ${generatedTripDaysRaw.length}'); // Debug log

      _tripNameController.text = tripHeader['name'] ?? '';
      _tripDescriptionController.text = tripHeader['description'] ?? '';

      if (tripHeader['startDate'] != null && tripHeader['endDate'] != null) {
        try {
          _selectedDateRange = DateTimeRange(
            start: DateTime.parse(tripHeader['startDate']),
            end: DateTime.parse(tripHeader['endDate']),
          );
          developer.log('Selected Date Range after AI: $_selectedDateRange'); // Debug log
        } catch (e) {
          developer.log('Error parsing AI generated dates: $e');
          _selectedDateRange = null;
        }
      } else {
        _selectedDateRange = null;
        developer.log('AI generated dates were null or missing.'); // Debug log
      }

      // Step 1: Initialize the structure based on the *newly set* _selectedDateRange.
      // This clears old data and creates the correct number of day entries in _currentTripDays
      // and new TextEditingController instances in _notesControllers.
      _initializeTripDaysStructure();

      // IMPORTANT: Create a TEMPORARY list to build the new _currentTripDays
      // to ensure Flutter sees a new list instance, potentially forcing a rebuild.
      List<Map<String, dynamic>> newTripDays = [];

      // Step 2: Now, populate the notes and activities into the newly created structure.
      for (int i = 0; i < generatedTripDaysRaw.length && i < _currentTripDays.length; i++) {
        final Map<String, dynamic> generatedDay =
            (generatedTripDaysRaw[i] as Map<String, dynamic>?) ?? {};

        // Debug log for each day
        developer.log('Processing Day $i: Notes: ${generatedDay['notes']}, Activities count: ${(generatedDay['activities'] as List?)?.length ?? 0}');

        // Set the text of the *newly created* TextEditingController
        _notesControllers[i]?.text = generatedDay['notes'] ?? '';

        // Safely extract and assign activities
        final List<dynamic> activitiesRaw = (generatedDay['activities'] as List<dynamic>?) ?? [];
        List<Map<String, dynamic>> dayActivities = activitiesRaw.cast<Map<String, dynamic>>();

        // Create a new map for the day to ensure full replacement
        newTripDays.add({
          "date": _currentTripDays[i]['date'], // Use date from initialized structure
          "notes": _notesControllers[i]!.text, // Get notes from controller
          "activities": dayActivities,
        });
      }
      // Finally, assign the newly built list to _currentTripDays
      _currentTripDays = newTripDays; // THIS IS THE AGGRESSIVE REASSIGNMENT

      developer.log('Final _currentTripDays count after population: ${_currentTripDays.length}');
      _currentTripDays.forEach((day) => developer.log('  Day: ${day['date']}, Notes: ${day['notes']}, Activities: ${day['activities'].length}')); // Detailed log
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Trip generated and loaded for editing!")),
    );
  }

  void _addActivity(int dayIndex) async {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Activity for Day ${dayIndex + 1}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Activity Type (e.g., Sightseeing, Food)'),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: startTimeController,
                decoration: const InputDecoration(labelText: 'Start Time (HH:MM)'),
                keyboardType: TextInputType.datetime,
              ),
              TextField(
                controller: endTimeController,
                decoration: const InputDecoration(labelText: 'End Time (HH:MM)'),
                keyboardType: TextInputType.datetime,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  List<Map<String, dynamic>> activities =
                  _currentTripDays[dayIndex]['activities'] as List<Map<String, dynamic>>;
                  activities.add({
                    'activity_type': typeController.text.trim(),
                    'name': nameController.text.trim(),
                    'description': descController.text.trim(),
                    'location': locationController.text.trim(),
                    'startTime': startTimeController.text.trim(),
                    'endTime': endTimeController.text.trim(),
                  });
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );

    nameController.dispose();
    typeController.dispose();
    descController.dispose();
    locationController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plan New Trip"),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            ElevatedButton.icon(
              onPressed: _showGenerateTripDialog,
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Generate Trip with AI"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                elevation: 4,
              ),
            ),
            const SizedBox(height: 30),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Trip Details",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _tripNameController,
                    decoration: const InputDecoration(
                      labelText: "Trip Name",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.travel_explore),
                      hintText: "e.g., My Summer Adventure",
                    ),
                    validator: (value) => value!.isEmpty ? "Enter a trip name" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tripDescriptionController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                      hintText: "e.g., A relaxing trip to explore new cultures",
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _selectDateRange(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _selectedDateRange == null
                          ? 'Select Trip Dates'
                          : 'Dates: ${dateFormatter.format(_selectedDateRange!.start)} - ${dateFormatter.format(_selectedDateRange!.end)}',
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Only display itinerary if _currentTripDays is not empty
            if (_currentTripDays.isNotEmpty) ...[
              Text(
                "Trip Itinerary",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ..._currentTripDays.asMap().entries.map((entry) {
                final int dayIndex = entry.key;
                final Map<String, dynamic> dayData = entry.value;
                final String dayDate = dayData['date'];

                // Ensure activities are correctly typed for rendering
                final List<Map<String, dynamic>> activities =
                (dayData['activities'] as List<dynamic>).cast<Map<String, dynamic>>();

                // Ensure controller exists and update its text (safely, if necessary)
                // This is less critical now due to _populateManualFormWithAIData's aggressive update
                if (!_notesControllers.containsKey(dayIndex)) {
                  _notesControllers[dayIndex] = TextEditingController(text: dayData['notes'] ?? '');
                }


                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ExpansionTile(
                    title: Text(
                      "Day ${dayIndex + 1}: ${dayDate}",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    childrenPadding: const EdgeInsets.all(16.0),
                    children: [
                      TextField(
                        controller: _notesControllers[dayIndex],
                        decoration: const InputDecoration(
                          labelText: "Notes for this day",
                          border: OutlineInputBorder(),
                          hintText: "e.g., Don't forget sunscreen!",
                        ),
                        maxLines: 2,
                        onChanged: (text) {
                          _currentTripDays[dayIndex]['notes'] = text.trim();
                        },
                      ),
                      const SizedBox(height: 15),
                      if (activities.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Activities:",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...activities.map((activity) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Card(
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity['name'] ?? 'No Name',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    "${activity['activity_type']} • ${activity['location'] ?? 'N/A'} • ${activity['startTime'] ?? ''} - ${activity['endTime'] ?? ''}",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                                  ),
                                  if (activity['description'] != null && activity['description'].isNotEmpty)
                                    Text(
                                      activity['description'],
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )).toList(),
                        const SizedBox(height: 10),
                      ],
                      OutlinedButton.icon(
                        onPressed: () => _addActivity(dayIndex),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text("Add New Activity"),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: _saveTripToJson,
              icon: const Icon(Icons.save),
              label: const Text("Save Trip"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}