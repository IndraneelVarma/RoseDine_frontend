import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rosedine/providers/meal_provider.dart';
import 'package:rosedine/widgets/menu_item_widget.dart';
import 'package:rosedine/widgets/recommendation_totals_widget.dart';

class MenuItemScreen extends ConsumerWidget {
  final String mealType;

  const MenuItemScreen({Key? key, required this.mealType}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final recommendations = ref.watch(recommendationsNotifierProvider);
    final isSaturday = selectedDate.weekday == DateTime.saturday;

    ref.listen<DateTime>(selectedDateProvider, (previous, next) {
      if (previous != next) {
        ref.read(recommendationsNotifierProvider.notifier).clearRecommendations();
      }
    });

    ref.listen<String>(selectedMealTypeProvider, (previous, next) {
      if (previous != next) {
        ref.read(recommendationsNotifierProvider.notifier).clearRecommendations();
      }
    });

    if (isSaturday && mealType == 'Dinner') {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'The Bon does not offer dinner on Saturday. Please go to Chauncey\'s.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }


    return ref.watch(menuItemsProvider(selectedDate)).when(
      data: (menuItems) {
        menuItems.sort((a, b) => a['name'].compareTo(b['name']));
        List<Widget> itemList = [];

        if (recommendations.isNotEmpty && recommendations.containsKey('items') && recommendations['items'].isNotEmpty) {

          itemList.add(Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: RecommendationTotalsWidget(totals: recommendations['totals']),
          ));

          itemList.addAll(recommendations['items'].map<Widget>((item) {
            final menuItemId = item['item']['id'];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: MenuItemWidget(
                menuItem: item['item'],
                onRatingUpdate: (userId, rating) {
                  ref.read(mealRepositoryProvider).sendReview(userId, menuItemId, rating);
                },
                getUserRating: (userId, menuItemId) async {
                  return await ref.read(mealRepositoryProvider).getUserRating(userId, menuItemId);
                },
                isRecommended: true,
              ),
            );
          }).toList());


          itemList.add(Divider(color: Color(0xFFAB8532), thickness: 5, height: 10));
        }

        itemList.addAll(menuItems.map<Widget>((item) {
          final menuItemId = item['id'];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: MenuItemWidget(
              menuItem: item,
              onRatingUpdate: (userId, rating) {
                ref.read(mealRepositoryProvider).sendReview(userId, menuItemId, rating);
              },
              getUserRating: (userId, menuItemId) async {
                return await ref.read(mealRepositoryProvider).getUserRating(userId, menuItemId);
              },
              isRecommended: false,
            ),
          );
        }).toList());

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(children: itemList),
        );

      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
