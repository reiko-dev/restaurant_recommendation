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

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_recommendation/src/widgets/sliver_fab_modified.dart';

import 'widgets/empty_list.dart';
import 'model/data.dart' as data;
import 'model/restaurant.dart';
import 'model/review.dart';
import 'widgets/app_bar.dart';
import 'widgets/review.dart';
import 'widgets/dialogs/review_create.dart';

class RestaurantPage extends StatefulWidget {
  static const route = '/restaurant';

  final String? _restaurantId;

  RestaurantPage({Key? key, required String? restaurantId})
      : _restaurantId = restaurantId,
        super(key: key);

  @override
  _RestaurantPageState createState() =>
      _RestaurantPageState(restaurantId: _restaurantId);
}

class _RestaurantPageState extends State<RestaurantPage> {
  _RestaurantPageState({required String? restaurantId}) {
    FirebaseAuth.instance
        .signInAnonymously()
        .then((UserCredential userCredential) {
      data.getRestaurant(restaurantId).then((Restaurant restaurant) {
        _currentReviewSubscription?.cancel();
        setState(() {
          if (userCredential.user!.displayName == null ||
              userCredential.user!.displayName!.isEmpty) {
            _userName = 'Anonymous (${kIsWeb ? "Web" : "Mobile"})';
          } else {
            _userName = userCredential.user!.displayName;
          }
          _restaurant = restaurant;
          _userId = userCredential.user!.uid;

          //
          _restaurantSubscription = FirebaseFirestore.instance
              .collection('restaurants')
              .doc(restaurantId)
              .snapshots()
              .listen((DocumentSnapshot restaurant) {
            setState(() {
              _restaurant = Restaurant.fromSnapshot(restaurant);
            });
          });

          ///mto bom
          ///5 stars
          // Initialize the reviews snapshot...
          //Move this to a new widget.
          _currentReviewSubscription = _restaurant!.reference!
              .collection('ratings')
              .orderBy('timestamp', descending: true)
              .snapshots()
              .listen((QuerySnapshot reviewSnap) {
            _isLoading = false;
            _reviews = reviewSnap.docs.map((DocumentSnapshot doc) {
              return Review.fromSnapshot(doc);
            }).toList();

            setState(() {});
          });
        });
      });
    });
  }

  bool _isLoading = true;
  StreamSubscription<QuerySnapshot>? _currentReviewSubscription;
  StreamSubscription<DocumentSnapshot>? _restaurantSubscription;
  Restaurant? _restaurant;
  String? _userId;
  String? _userName;
  List<Review> _reviews = <Review>[];

  @override
  void dispose() {
    _currentReviewSubscription?.cancel();
    _restaurantSubscription?.cancel();
    super.dispose();
  }

  void _onCreateReviewPressed(BuildContext context) async {
    final newReview = await showDialog<Review>(
      context: context,
      builder: (_) => ReviewCreateDialog(
        userId: _userId,
        userName: _userName,
      ),
    );
    if (newReview != null) {
      // Save the review
      return data.addReview(
        restaurantId: _restaurant!.id,
        review: newReview,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SliverFabModified(
              floatingWidget: FloatingActionButton(
                tooltip: 'Add a review',
                backgroundColor: Colors.amber,
                child: Icon(Icons.add),
                onPressed: () => _onCreateReviewPressed(context),
              ),
              floatingPosition: FloatingPosition(right: 16),
              expandedHeight: RestaurantAppBar.appBarHeight,
              slivers: <Widget>[
                RestaurantAppBar(
                  restaurant: _restaurant,
                  onClosePressed: () => Navigator.pop(context),
                ),
                _reviews.isNotEmpty
                    ? SliverPadding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(_reviews
                              .map((Review review) =>
                                  RestaurantReview(review: review))
                              .toList()),
                        ),
                      )
                    : SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyListView(
                          child: Text('${_restaurant!.name} has no reviews.'),
                          onPressed: () => _onCreateReviewPressed(context),
                        ),
                      ),
              ],
            ),
    );
  }
}

class RestaurantPageArguments {
  final String? id;

  RestaurantPageArguments({required this.id});
}
