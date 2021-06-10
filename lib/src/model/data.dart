// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import './filter.dart';
import './restaurant.dart';
import './review.dart';

//Returns their generatedId
Future<String> addRestaurant(Restaurant restaurant) async {
  final restaurants = FirebaseFirestore.instance.collection('restaurants');

  final doc = await restaurants.add({
    'avgRating': restaurant.avgRating,
    'category': restaurant.category,
    'city': restaurant.city,
    'name': restaurant.name,
    'numRatings': restaurant.numRatings,
    'photo': restaurant.photo,
    'price': restaurant.price,
  });
  return doc.id;
}

Stream<QuerySnapshot> loadAllRestaurants() {
  return FirebaseFirestore.instance
      .collection('restaurants')
      .orderBy('avgRating', descending: true)
      .limit(50)
      .snapshots();
}

List<Restaurant> getRestaurantsFromQuery(QuerySnapshot snapshot) {
  return snapshot.docs.map((DocumentSnapshot doc) {
    return Restaurant.fromSnapshot(doc);
  }).toList();
}

Future<Restaurant> getRestaurant(String? restaurantId) {
  return FirebaseFirestore.instance
      .collection('restaurants')
      .doc(restaurantId)
      .get()
      .then((doc) => Restaurant.fromSnapshot(doc));
}

//
//Makes the use of transaction to make the update of different data about reviews an atomic change.
//It means: Or all the changes are stored or none of then.
//
Future<void> addReview({String? restaurantId, Review? review}) {
  final restaurant =
      FirebaseFirestore.instance.collection('restaurants').doc(restaurantId);

  final newReview = restaurant.collection('ratings').doc();

  return FirebaseFirestore.instance.runTransaction((Transaction transaction) {
    return transaction
        .get(restaurant)
        .then((DocumentSnapshot doc) => Restaurant.fromSnapshot(doc))
        .then((Restaurant fresh) {
      final newRatings = fresh.numRatings! + 1;
      final newAverage =
          ((fresh.numRatings! * fresh.avgRating!) + review!.rating!) /
              newRatings;

      transaction.update(restaurant, {
        'numRatings': newRatings,
        'avgRating': newAverage,
      });

      transaction.set(newReview, {
        'rating': review.rating,
        'text': review.text,
        'userName': review.userName,
        'timestamp': review.timestamp ?? FieldValue.serverTimestamp(),
        'userId': review.userId,
      });
    });
  });
}

Stream<QuerySnapshot> loadFilteredRestaurants(Filter filter) {
  Query collection = FirebaseFirestore.instance.collection('restaurants');

  if (filter.category != null) {
    collection = collection.where('category', isEqualTo: filter.category);
  }

  if (filter.city != null) {
    collection = collection.where('city', isEqualTo: filter.city);
  }

  if (filter.price != null) {
    collection = collection.where('price', isEqualTo: filter.price);
  }

  return collection
      .orderBy(filter.sort ?? 'avgRating', descending: true)
      .limit(50)
      .snapshots();
}

///Stores a random number of reviews for each restaurant, using a WriteBatch.
Future<void> addRestaurantsBatch(
  List<Restaurant> restaurantsToStoreOnDB,
  String userName,
  String userId,
) async {
  final batch = FirebaseFirestore.instance.batch();

  //Will hold a list of addRestaurant futures.
  //After each future a list of reviews is added to db.
  final List<Future> futures = [];

  restaurantsToStoreOnDB.forEach((Restaurant restaurant) {
    final randomReviews = generateRandomReviews(userId, userName);

    double avgRating = 0;

    randomReviews.forEach((element) {
      avgRating += element.rating!;
    });

    if (avgRating > 1) {
      avgRating /= randomReviews.length;
    }

    //Could just simply adds a CopyWith method on the Restaurant class.
    final updatedRestaurant = Restaurant(
      category: restaurant.category,
      city: restaurant.city,
      id: restaurant.id,
      name: restaurant.name,
      photo: restaurant.photo,
      reference: restaurant.reference,
      price: restaurant.price,
      numRatings: randomReviews.length,
      avgRating: avgRating,
    );

    futures.add(
      addRestaurant(updatedRestaurant).then((id) {
        final restaurantDoc =
            FirebaseFirestore.instance.collection('restaurants').doc(id);

        randomReviews.forEach((review) {
          final ratingsCollection = restaurantDoc.collection('ratings').doc();
          batch.set(
            ratingsCollection,
            review.toMap(),
          );
        });
      }),
    );
  });

  Future.wait(futures).then((value) => batch.commit());
}

List<Review> generateRandomReviews(String userId, String userName) {
  final numReviews = Random().nextInt(7);
  final List<Review> reviews = [];
  for (var i = 0; i < numReviews; i++) {
    reviews.add(
      Review.random(userId: userId, userName: userName),
    );
  }

  return reviews;
}
