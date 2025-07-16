// lib/plan_trip_screen.dart

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:voyageui/src/app/screens/bookmark_screen.dart';
import 'package:voyageui/src/app/screens/profile_screen.dart';
import 'package:voyageui/src/app/screens/summary_screen.dart';

// Import the new data models
import '../models/trip_models.dart';

class PlanTripScreen extends StatefulWidget {
  @override
  _PlanTripScreenState createState() => _PlanTripScreenState();
}

// Add new states for loading and displaying the plan
enum FormStep { initial, primaryDetails, preferences, loading, planGenerated }

class _PlanTripScreenState extends State<PlanTripScreen> {
  // Navigation and general state
  int _currentPageIndex = 0;
  final NavigationDestinationLabelBehavior _labelBehavior =
      NavigationDestinationLabelBehavior.alwaysShow;

  // Form state management
  FormStep _formStep = FormStep.initial;
  final _primaryDetailsFormKey = GlobalKey<FormState>();
  late PageController _pageController;
  int _preferencePageIndex = 0;

  // Data for the generated plan
  TripPlan? _generatedPlan;

  // --- Form Data ---
  final _destinationController = TextEditingController();
  final _originController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  String? _transportMode;
  bool? _includeRestaurants;
  final _foodPreferenceController = TextEditingController();
  bool? _isKidFriendly;
  double _relaxationLevel = 2.0;
  String? _budget;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _preferencePageIndex = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    // Clean up all controllers
    _destinationController.dispose();
    _originController.dispose();
    _foodPreferenceController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(FormStep step) {
    setState(() {
      _formStep = step;
    });
  }

  void _handlePrimaryDetailsSubmit() {
    if (_primaryDetailsFormKey.currentState!.validate()) {
      _goToStep(FormStep.preferences);
    }
  }

  Future<void> _submitFinalForm() async {
    _goToStep(FormStep.loading); // <-- Show loading indicator

    final relaxationLevels = ['Fast-Paced', 'Standard', 'Relaxed', 'Very Relaxed', 'Maximum Chill'];
    final requestPayload = {
      'start_location': _originController.text,
      'destination': _destinationController.text,
      'start_date': DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start),
      'end_date': DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end),
      'include_restaurant': _includeRestaurants,
      'food_preference': _includeRestaurants == true ? _foodPreferenceController.text : 'None',
      'kid_friendly': _isKidFriendly,
      'relaxation_level': relaxationLevels[_relaxationLevel.round()],
      'budget': _budget,
      'description': ''
    };
    var local = 'http://10.0.2.2:3000';
    var render = 'https://voyage-v1.onrender.com';
    final url = Uri.parse('$local/trips/generate');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        developer.log("Response: ${jsonDecode(response.body)}");
        final Map<String, dynamic> responseData = jsonDecode(response.body);


        // Parse the data and transition to the plan view
        setState(() {
          _generatedPlan = TripPlan.fromJson(responseData);
          _formStep = FormStep.planGenerated;
        });
      } else {
        developer.log('AI generation failed: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to generate trip: ${response.body}")));
        _goToStep(FormStep.preferences); // Go back to the form
      }
    } catch (e) {
      developer.log('Error calling AI generation backend: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error connecting to AI service: $e")));
      _goToStep(FormStep.preferences); // Go back to the form
    }
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voyage Pilot'),
        leading: _formStep != FormStep.initial && _currentPageIndex == 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            // Handle back navigation between steps
            if (_formStep == FormStep.planGenerated) {
              _goToStep(FormStep.preferences);
            } else if (_formStep == FormStep.preferences) {
              _goToStep(FormStep.primaryDetails);
            } else if (_formStep == FormStep.primaryDetails) {
              _goToStep(FormStep.initial);
            }
          },
        )
            : null,
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        labelBehavior: _labelBehavior,
        selectedIndex: _currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _goToStep(FormStep.initial);
            _currentPageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(selectedIcon: Icon(Icons.bookmark), icon: Icon(Icons.bookmark_border), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  // --- Body Building Logic ---
  Widget _buildBody() {
    return IndexedStack(
      index: _currentPageIndex,
      children: <Widget>[
        _buildExplorePage(),
        const BookmarkScreen(),
        const ProfileScreen(),
      ],
    );
  }

  Widget _buildExplorePage() {
    switch (_formStep) {
      case FormStep.initial:
        return _buildStartPlanningButton();
      case FormStep.primaryDetails:
        return _buildPrimaryDetailsForm();
      case FormStep.preferences:
        return _buildPreferencesForm();
      case FormStep.loading:
        return const Center(child: CircularProgressIndicator());
      case FormStep.planGenerated:
        return _buildPlanView();
    }
  }

  // --- UI for Each Form Step ---
  // ... (Your _buildStartPlanningButton, _buildPrimaryDetailsForm, and other form-building widgets remain here)
  // --- Reusable Widgets for Preference Questions ---
  Widget _buildQuestionCard(String title, Widget child) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransportSelector() {
    return Wrap(
      spacing: 12.0,
      alignment: WrapAlignment.center,
      children: ['Car', 'Plane', 'Train', 'Bus'].map((mode) {
        return ChoiceChip(
          label: Text(mode),
          selected: _transportMode == mode,
          onSelected: (selected) => setState(() => _transportMode = mode),
          avatar: Icon(mode == 'Car' ? Icons.directions_car : mode == 'Plane' ? Icons.flight : mode == 'Train' ? Icons.train : Icons.directions_bus),
        );
      }).toList(),
    );
  }

  Widget _buildBooleanSelector({required bool? value, required ValueChanged<bool> onChanged}) {
    return ToggleButtons(
      isSelected: [value == true, value == false],
      onPressed: (index) => onChanged(index == 0),
      borderRadius: BorderRadius.circular(8),
      children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Yes')), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('No'))],
    );
  }

// In lib/screens/plan_trip_screen.dart

  Widget _buildStartPlanningButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Spacer to push content to the center
          const Spacer(flex: 2),

          // App title and description text
          Text(
            'Welcome',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your personal AI travel assistant. Plan detailed, multi-day trips in seconds. Just tell us where you want to go and what you like to do.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 40),

          // The main button to start the planning process
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onPressed: () => _goToStep(FormStep.primaryDetails),
            icon: const Icon(Icons.luggage_rounded),
            label: const Text("Start Planning"),
          ),

          // Spacer to push the footer text to the bottom
          const Spacer(flex: 3),

          // Footer text
          Text(
            'Powered by Gemini',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryDetailsForm() {
    // UI for Step 1: Where, From, When
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _primaryDetailsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Plan Your Adventure", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(labelText: 'Where?', border: OutlineInputBorder(), prefixIcon: Icon(Icons.search)),
                validator: (v) => v!.isEmpty ? 'Please enter a destination' : null),
            const SizedBox(height: 16),
            TextFormField(
                controller: _originController,
                decoration: const InputDecoration(labelText: 'From?', border: OutlineInputBorder(), prefixIcon: Icon(Icons.flight_takeoff)),
                validator: (v) => v!.isEmpty ? 'Please enter a starting point' : null),
            const SizedBox(height: 16),
            FormField<DateTimeRange>(
                builder: (state) => InkWell(
                    onTap: () async {
                      final picked = await showDateRangePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2026));
                      if (picked != null) setState(() => _selectedDateRange = picked);
                    },
                    child: InputDecorator(
                        decoration: InputDecoration(labelText: 'When?', border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.calendar_today), errorText: state.errorText),
                        child: Text(_selectedDateRange == null ? 'Select your dates' : '${DateFormat.yMMMd().format(_selectedDateRange!.start)} - ${DateFormat.yMMMd().format(_selectedDateRange!.end)}'))),
                validator: (v) => _selectedDateRange == null ? 'Please select a date range' : null),
            const Spacer(),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    onPressed: _handlePrimaryDetailsSubmit,
                    child: const Text('Next'))),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesForm() {
    // UI for Step 2: Swiping Preferences
    final preferencePages = [
      _buildQuestionCard('Preferred mode of transport?', _buildTransportSelector()),
      _buildQuestionCard('Restaurant & Food Preferences', _buildRestaurantSelector()), // Dynamic card
      _buildQuestionCard('Is this a kid-friendly trip?', _buildBooleanSelector(value: _isKidFriendly, onChanged: (val) => setState(() => _isKidFriendly = val))),
      _buildQuestionCard('How relaxed should the trip be?', _buildRelaxationSelector()), // 5-level slider
      _buildQuestionCard("What's your budget like?", _buildBudgetSelector()),
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text("Tell Us More...", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
              child: PageView(controller: _pageController, children: preferencePages)),
          _buildProgressDots(preferencePages.length),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon( // Use ElevatedButton.icon for a nice touch
              icon: const Icon(Icons.auto_awesome),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent, // Make the final button stand out
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: _submitFinalForm,
              label: const Text('Generate Plan'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRestaurantSelector() {
    return Column(
      children: [
        const Text("Include restaurants?", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        ToggleButtons(
          isSelected: [_includeRestaurants == true, _includeRestaurants == false],
          onPressed: (index) {
            setState(() {
              _includeRestaurants = (index == 0);
              // If 'No' is selected, clear the food preference text
              if (_includeRestaurants == false) {
                _foodPreferenceController.clear();
              }
            });
          },
          borderRadius: BorderRadius.circular(8),
          children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Yes')), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('No'))],
        ),
        // Conditionally show the food preference text field with an animation
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SizeTransition(sizeFactor: animation, child: child);
          },
          child: _includeRestaurants == true
              ? Padding(
            key: const ValueKey('food_pref_field'),
            padding: const EdgeInsets.only(top: 24.0),
            child: TextFormField(
              controller: _foodPreferenceController,
              decoration: const InputDecoration(
                labelText: 'Any food preferences?',
                hintText: 'e.g., Vegan, Gluten-free',
                border: OutlineInputBorder(),
              ),
            ),
          )
              : const SizedBox.shrink(key: ValueKey('food_pref_empty')),
        ),
      ],
    );
  }

  Widget _buildRelaxationSelector() {
    final labels = ['Fast-Paced', 'Standard', 'Relaxed', 'Very Relaxed', 'Maximum Chill'];
    return Column(
      children: [
        Slider(
          value: _relaxationLevel,
          min: 0,
          max: 4,
          divisions: 4,
          label: labels[_relaxationLevel.round()],
          onChanged: (double value) {
            setState(() {
              _relaxationLevel = value;
            });
          },
        ),
        Text(labels[_relaxationLevel.round()], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBudgetSelector() {
    return Wrap(
      spacing: 12.0,
      alignment: WrapAlignment.center,
      children: ['Budget', 'Mid-Range', 'Luxury'].map((budget) {
        return ChoiceChip(
          label: Text(budget),
          selected: _budget == budget,
          onSelected: (selected) => setState(() => _budget = budget),
          avatar: Text(budget == 'Budget' ? '\$' : budget == 'Mid-Range' ? '\$\$' : '\$\$\$'),
        );
      }).toList(),
    );
  }

  // Widget _buildProgressDots(int pageCount) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: List.generate(pageCount, (index) {
  //       return Container(
  //         width: 10,
  //         height: 10,
  //         margin: const EdgeInsets.symmetric(horizontal: 4),
  //         decoration: BoxDecoration(
  //           shape: BoxShape.circle,
  //           color: _preferencePageIndex == index ? Colors.blueAccent : Colors.grey.shade300,
  //         ),
  //       );
  //     }),
  //   );
  // }

  // --- New Widgets for Displaying the Itinerary ---
  Widget _buildPlanView() {
    if (_generatedPlan == null) {
      return const Center(child: Text("Error: No plan was generated."));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _generatedPlan!.tripDays.length,
      itemBuilder: (context, dayIndex) {
        final day = _generatedPlan!.tripDays[dayIndex];
        // Using an ExpansionTile to make the UI cleaner for long trips
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            title: Text(
              "Day ${dayIndex + 1}: ${DateFormat.yMMMEd().format(day.date)}",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Text(
              day.notes,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            initiallyExpanded: true, // Keep days expanded by default
            childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            children: [
              ListView.separated(
                itemCount: day.activities.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, activityIndex) {
                  // This is the new, interactive activity card
                  return _buildActivityCard(day.activities[activityIndex], dayIndex, activityIndex);
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityCard(Activity activity, int dayIndex, int activityIndex) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Activity Header with Edit Button ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  activity.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent),
                tooltip: "Edit Activity",
                onPressed: () async {
                  final updatedActivity = await Navigator.of(context).push<Activity>(
                    MaterialPageRoute(
                      builder: (context) => SummaryScreen(activity: activity),
                    ),
                  );

                  if (updatedActivity != null) {
                    setState(() {
                      _generatedPlan!.tripDays[dayIndex].activities[activityIndex] = updatedActivity;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // --- Activity Details ---
          _buildDetailRow(Icons.schedule_rounded, "${activity.startTime} - ${activity.endTime}"),
          _buildDetailRow(Icons.location_on_rounded, activity.location),
          _buildDetailRow(Icons.info_outline_rounded, activity.description),

          // --- Horizontally Scrollable Alternatives Section ---
          if (activity.alternatives.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text("Alternatives", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 120, // Constrain the height of the horizontal list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: activity.alternatives.length,
                itemBuilder: (context, altIndex) {
                  return _buildAlternativeCard(activity.alternatives[altIndex], dayIndex, activityIndex, altIndex);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

// A helper widget for displaying a row of details with an icon
  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

// A helper widget for the small, horizontally-scrolling alternative cards
  Widget _buildAlternativeCard(Activity alternative, int dayIndex, int mainActivityIndex, int altIndex) {
    return SizedBox(
      width: 220,
      child: Card(
        // Make the alternative cards slightly different to stand out
        color: Colors.white.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(alternative.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                  ),
                  child: const Text("Swap with this"),
                  onPressed: () {
                    setState(() {
                      // --- The Swap Logic ---
                      // 1. Get the original activity that will be replaced.
                      final originalActivity = _generatedPlan!.tripDays[dayIndex].activities[mainActivityIndex];

                      // 2. The chosen alternative becomes the new main activity.
                      _generatedPlan!.tripDays[dayIndex].activities[mainActivityIndex] = alternative;

                      // 3. Create the new list of alternatives: it's the original's alternatives,
                      //    minus the one we just chose, plus the original activity itself.
                      List<Activity> newAlternatives = List.from(originalActivity.alternatives)
                        ..removeAt(altIndex)
                        ..add(originalActivity);

                      // 4. Assign the new list of alternatives to our new main activity.
                      _generatedPlan!.tripDays[dayIndex].activities[mainActivityIndex].alternatives = newAlternatives;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDots(int pageCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Use the theme's accent color for the active dot
            color: _preferencePageIndex == index ? Theme.of(context).colorScheme.primary : Colors.grey.shade700,
          ),
        );
      }),
    );
  }
}