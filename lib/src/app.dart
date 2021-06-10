import 'package:flutter/material.dart';
import 'package:restaurant_recommendation/src/restaurant_page.dart';

import 'home_page.dart';

class FriendlyEatsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FriendlyEats',
      theme: ThemeData(
        primaryColor: Colors.purple,
        accentColor: Colors.amber,
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case RestaurantPage.route:
            final RestaurantPageArguments? arguments =
                settings.arguments as RestaurantPageArguments?;

            return MaterialPageRoute(
              builder: (context) {
                return RestaurantPage(
                  restaurant: arguments!.restaurant,
                );
              },
            );
          default:
            // return MaterialPageRoute(
            //     builder: (context) => RestaurantPage(
            //           restaurantId: 'lV81npEeboEActMpUJjn',
            //         ));
            // Everything defaults to home, but maybe we want a custom 404 here
            return MaterialPageRoute(builder: (context) => HomePage());
        }
      },
    );
  }
}
