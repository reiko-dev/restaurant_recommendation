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
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_recommendation/src/restaurant_page.dart';
import 'package:restaurant_recommendation/src/widgets/auth_form.dart';

import 'model/data.dart' as data;
import 'model/filter.dart';
import 'model/restaurant.dart';
import 'widgets/empty_list.dart';
import 'widgets/filter_bar.dart';
import 'widgets/grid.dart';
import 'widgets/dialogs/filter_select.dart';

class HomePage extends StatefulWidget {
  static const route = '/';

  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Verifies if there's a user authenticated if not show a sign-in/up form.

  StreamSubscription<QuerySnapshot>? _currentSubscription;
  bool _isLoading = true;
  List<Restaurant> _restaurants = <Restaurant>[];
  Filter? _filter;

  User? _user;
  late StreamSubscription<User?> _userChangesSubscription;

  _HomePageState() {
    _userChangesSubscription =
        FirebaseAuth.instance.userChanges().listen((newUser) {
      _user = newUser;

      if (_user != null) {
        _currentSubscription =
            data.loadAllRestaurants().listen(_updateRestaurants);
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    _currentSubscription?.cancel();
    _userChangesSubscription.cancel();
    super.dispose();
  }

  void _updateRestaurants(QuerySnapshot snapshot) {
    setState(() {
      _isLoading = false;
      _restaurants = data.getRestaurantsFromQuery(snapshot);
    });
  }

  Future<void> _onAddRandomRestaurantsPressed() async {
    final numReviews = Random().nextInt(10) + 20;

    final restaurants = List.generate(numReviews, (_) => Restaurant.random());

    data.addRestaurantsBatch(
      restaurants,
      _user!.email!,
      _user!.uid,
    );
  }

  Future<void> _onFilterBarPressed() async {
    final filter = await showDialog<Filter>(
      context: context,
      builder: (_) => FilterSelectDialog(filter: _filter),
    );
    if (filter != null) {
      await _currentSubscription?.cancel();
      setState(() {
        _isLoading = true;
        _filter = filter;
        if (filter.isDefault) {
          _currentSubscription =
              data.loadAllRestaurants().listen(_updateRestaurants);
        } else {
          _currentSubscription =
              data.loadFilteredRestaurants(filter).listen(_updateRestaurants);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.restaurant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        title: Text('FriendlyEats'),
        bottom: PreferredSize(
          preferredSize: Size(320, 48),
          child: Padding(
            padding: EdgeInsets.fromLTRB(6, 0, 6, 4),
            child: _user != null
                ? FilterBar(
                    filter: _filter,
                    onPressed: _onFilterBarPressed,
                  )
                : SizedBox.shrink(),
          ),
        ),
      ),
      body: Center(
        child: _user == null
            ? AuthForm()
            : Container(
                constraints: BoxConstraints(maxWidth: 1280),
                child: _isLoading
                    ? CircularProgressIndicator()
                    : _restaurants.isNotEmpty
                        ? RestaurantGrid(
                            restaurants: _restaurants,
                            onRestaurantPressed: (restaurant) {
                              /// TODO: Share the link of the restaurant through deep links on web
                              ///
                              Navigator.pushNamed(
                                context,
                                RestaurantPage.route,
                                arguments: RestaurantPageArguments(
                                    restaurant: restaurant),
                              );
                            },
                          )
                        : EmptyListView(
                            child: Text('FriendlyEats has no restaurants yet!'),
                            onPressed: _onAddRandomRestaurantsPressed,
                          ),
              ),
      ),
    );
  }
}
