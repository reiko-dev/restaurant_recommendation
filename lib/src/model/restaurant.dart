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

import './values.dart';

typedef RestaurantPressedCallback = void Function(String? restaurantId);

typedef CloseRestaurantPressedCallback = void Function();

class Restaurant {
  final String? id;
  final String? name;
  final String? category;
  final String? city;
  final double? avgRating;
  final int? numRatings;
  final int? price;
  final String? photo;
  final DocumentReference? reference;

  Restaurant({
    this.avgRating,
    this.category,
    this.city,
    this.id,
    this.name,
    this.numRatings,
    this.photo,
    this.price,
    this.reference,
  });

  Restaurant._({this.name, this.category, this.city, this.price, this.photo})
      : id = null,
        numRatings = 0,
        avgRating = 0,
        reference = null;

  Restaurant.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot.id,
        name = (snapshot.data() as Map)['name'],
        category = (snapshot.data() as Map)['category'],
        city = (snapshot.data() as Map)['city'],
        avgRating = (snapshot.data() as Map)['avgRating'].toDouble(),
        numRatings = (snapshot.data() as Map)['numRatings'],
        price = (snapshot.data() as Map)['price'],
        photo = (snapshot.data() as Map)['photo'],
        reference = snapshot.reference;

  factory Restaurant.random() {
    return Restaurant._(
      category: getRandomCategory(),
      city: getRandomCity(),
      name: getRandomRestaurantName(),
      price: Random().nextInt(3) + 1,
      photo: getRandomPhoto(),
    );
  }

  @override
  String toString() {
    return '(id: $id, name: $name, Category: $category, city: $city, avgRating: $avgRating, ratings: $numRatings, price: $price, photo: $photo)';
  }
}
