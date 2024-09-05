import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rosedine/providers/meal_provider.dart';
import 'package:rosedine/user_profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'menu_item_screen.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedMealType = ref.watch(selectedMealTypeProvider);

    ref.listen<DateTime>(selectedDateProvider, (previous, next) {
      if (previous != next) {
        final initialMealType = _getInitialMealType(next);
        ref.read(selectedMealTypeProvider.notifier).state = initialMealType;
      }
    });

    final initialMealType = _getInitialMealType(selectedDate);
    if (selectedMealType.isEmpty) {
      Future(() {
        ref.read(selectedMealTypeProvider.notifier).state = initialMealType;
      });
    }


    String mealTime = getMealTime(selectedDate, selectedMealType);

    final navBarItems = _getNavBarItems(selectedDate);
    final currentIndex =
    navBarItems.indexWhere((item) => item.label == selectedMealType);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.person, color: Colors.grey.shade300),
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserProfileScreen()),
                  );
                },
                tooltip: 'User Profile',
              ),
              IconButton(
                icon: Text(
                  'Rec.',
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  ref.read(recommendationsNotifierProvider.notifier).fetchRecommendations(selectedDate, selectedMealType);
                },
                tooltip: 'Recommendations',
              ),
              const SizedBox(width: 5),
              IconButton(
                iconSize: 24,
                padding: EdgeInsets.zero,
                icon: Icon(Icons.arrow_left, color: Colors.grey.shade300),
                onPressed: () {
                  if (selectedDate.isAfter(DateTime.now())) {
                    ref.read(selectedDateProvider.notifier).state =
                        selectedDate.subtract(const Duration(days: 1));
                  }
                },
                tooltip: 'Previous Day',
              ),
              Column(
                children: [
                  Text(
                    DateFormat('EE, dd MMM').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    mealTime,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(width: 5),
              IconButton(
                iconSize: 24,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_right, color: Colors.white),
                onPressed: () {
                  if (selectedDate.difference(DateTime.now()).inDays < 5) {
                    ref.read(selectedDateProvider.notifier).state =
                        selectedDate.add(const Duration(days: 1));
                  }
                },
                tooltip: 'Next Day',
              ),
              const SizedBox(width: 5),
              IconButton(
                icon: Icon(Icons.mail, color: Colors.grey.shade300),
                padding: EdgeInsets.zero,
                onPressed: () => _sendEmail(),
                tooltip: 'Send feedback',
              ),
              const SizedBox(width: 5),
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: getMealStatusColor(selectedDate, selectedMealType),
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(right: 8),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: MenuItemScreen(mealType: selectedMealType),
      bottomNavigationBar: BottomNavigationBar(
        items: navBarItems.map((item) {
          return BottomNavigationBarItem(
            icon: item.icon,
            label: item.label,
          );
        }).toList(),
        currentIndex: currentIndex >= 0 ? currentIndex : 0,
        selectedItemColor: const Color(0xFFAB8532),
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.blueGrey[900],
        onTap: (index) {
          ref.read(selectedMealTypeProvider.notifier).state =
          navBarItems[index].label!;
        },
      ),
    );
  }

  Future<void> _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@bonappetit.com',
      queryParameters: {
        'subject': 'Feedback',
      },
    );

    // if (await canLaunchUrl(emailLaunchUri)) { // Bug with this stuff
      await launchUrl(emailLaunchUri);
    // } else {
    //   throw 'Could not launch email';
    // }
  }

  String _getInitialMealType(DateTime selectedDate) {
    final isWeekend = selectedDate.weekday == DateTime.saturday ||
        selectedDate.weekday == DateTime.sunday;

    if (isWeekend) {
      return 'Brunch';
    } else {
      final currentTime = TimeOfDay.now();
      if (currentTime.hour < 11) {
        return 'Breakfast';
      } else if (currentTime.hour < 17) {
        return 'Lunch';
      } else {
        return 'Dinner';
      }
    }
  }

  String getMealTime(DateTime selectedDate, String mealType) {
    bool isWeekend = selectedDate.weekday == DateTime.saturday ||
        selectedDate.weekday == DateTime.sunday;
    switch (mealType) {
      case 'Breakfast':
        return '7:00 AM - 10:00 AM';
      case 'Brunch':
        return '10:00 AM - 2:00 PM';
      case 'Lunch':
        return '11:00 AM - 2:00 PM';
      case 'Dinner':
        return isWeekend ? '5:00 PM - 7:00 PM' : '5:00 PM - 8:00 PM';
      default:
        return '';
    }
  }

  Color getMealStatusColor(DateTime selectedDate, String mealType) {
    final now = DateTime.now();
    final currentHour = now.hour + now.minute / 60.0;
    bool isWeekend = selectedDate.weekday == DateTime.saturday ||
        selectedDate.weekday == DateTime.sunday;
    bool isSelectedDateToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
    bool isOpen = false;

    if (!isSelectedDateToday) {
      return Colors.red;
    }

    switch (mealType) {
      case 'Breakfast':
        isOpen = !isWeekend && currentHour >= 7 && currentHour < 10;
        break;
      case 'Brunch':
        isOpen = isWeekend && currentHour >= 10 && currentHour < 14;
        break;
      case 'Lunch':
        isOpen = !isWeekend && currentHour >= 11 && currentHour < 14;
        break;
      case 'Dinner':
        isOpen = currentHour >= 17 && currentHour < (isWeekend ? 19 : 20);
        break;
    }

    return isOpen ? Colors.green : Colors.red;
  }

  List<BottomNavigationBarItem> _getNavBarItems(DateTime selectedDate) {
    bool isWeekend = selectedDate.weekday == DateTime.saturday ||
        selectedDate.weekday == DateTime.sunday;

    return [
      if (isWeekend)
        const BottomNavigationBarItem(
          icon: Icon(Icons.free_breakfast),
          label: 'Brunch',
        ),
      if (!isWeekend)
        const BottomNavigationBarItem(
          icon: Icon(Icons.free_breakfast),
          label: 'Breakfast',
        ),
      if (!isWeekend)
        const BottomNavigationBarItem(
          icon: Icon(Icons.lunch_dining),
          label: 'Lunch',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.dinner_dining),
        label: 'Dinner',
      ),
    ];
  }

}