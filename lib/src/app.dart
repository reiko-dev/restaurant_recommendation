import 'package:flutter/material.dart';
import 'package:restaurant_recommendation/src/rastaurant_page.dart';

import 'home_page.dart';

class FriendlyEatsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FriendlyEats',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case RestaurantPage.route:
            final RestaurantPageArguments arguments = settings.arguments;
            return MaterialPageRoute(
                builder: (context) => RestaurantPage(
                      restaurantId: arguments.id,
                    ));
            break;
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
