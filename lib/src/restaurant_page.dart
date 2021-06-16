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
import 'package:restaurant_recommendation/src/home_page.dart';
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

  final Restaurant? restaurant;
  final String? id;

  RestaurantPage({
    this.restaurant,
    this.id,
  }) : super(key: ValueKey(id ?? restaurant!.id));

  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  //Makes different transitions based on the value passed to the constructor.
  //If a full restaurant is passed we can make a proper Hero animation
  //
  StreamSubscription<QuerySnapshot>? _currentReviewSubscription;
  StreamSubscription<DocumentSnapshot>? _restaurantSubscription;
  Restaurant? _restaurant;
  List<Review> _reviews = <Review>[];
  bool isLoadingReviews = true;

  late StreamSubscription<User?> _userSubscription;
  User? _user;
  String restaurantId = '';

  @override
  void initState() {
    super.initState();
    if (widget.restaurant != null) {
      restaurantId = widget.restaurant!.id!;
      _restaurant = widget.restaurant;
    } else
      restaurantId = widget.id!;

    _user = FirebaseAuth.instance.currentUser;

    _userSubscription = FirebaseAuth.instance.userChanges().listen((user) {
      _user = user;

      if (user != null) {
        getRestaurant();
      }
    });
  }

  getRestaurant() {
    data.getRestaurant(restaurantId).then((Restaurant restaurant) {
      setState(() {
        _restaurant = restaurant;

        // Initialize the restaurant snapshot...
        _restaurantSubscription = _restaurant!.reference!
            .snapshots()
            .listen((DocumentSnapshot restaurant) {
          setState(() {
            _restaurant = Restaurant.fromSnapshot(restaurant);
          });
        });

        // Initialize the reviews snapshot...
        _currentReviewSubscription = _restaurant!.reference!
            .collection('ratings')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((QuerySnapshot reviewSnap) {
          _reviews = reviewSnap.docs.map((DocumentSnapshot doc) {
            return Review.fromSnapshot(doc);
          }).toList();

          setState(() {
            isLoadingReviews = false;
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _currentReviewSubscription?.cancel();
    _restaurantSubscription?.cancel();
    _userSubscription.cancel();
    super.dispose();
  }

  void _onCreateReviewPressed(BuildContext context) async {
    final newReview = await showDialog<Review>(
      context: context,
      builder: (_) => ReviewCreateDialog(
        userId: _user!.uid,
        userName: _user!.email!,
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
    if (_user == null) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        Navigator.pushNamed(
          context,
          HomePage.route,
        );
      });
      return Scaffold(
        body: Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    return Scaffold(
      body: SliverFabModified(
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
            restaurant: _restaurant!,
            onClosePressed: () => Navigator.pop(context),
          ),
          if (isLoadingReviews)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.amber,
                ),
              ),
            ),
          if (!isLoadingReviews)
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
  final Restaurant? restaurant;

  RestaurantPageArguments({this.id, this.restaurant})
      : assert(id != null || restaurant != null);
}
