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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../model/restaurant.dart';
import 'stars.dart';

class RestaurantCard extends StatefulWidget {
  RestaurantCard({
    this.restaurant,
    required RestaurantPressedCallback onRestaurantPressed,
  }) : _onPressed = onRestaurantPressed;

  final Restaurant? restaurant;

  final RestaurantPressedCallback _onPressed;

  @override
  _RestaurantCardState createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  //TODO: Listen to changes on the Restaurant doc to update it accordingly to changes on the firestore
  //Because the stars are not getting updating when a new review is mode on a restaurant page.
  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
      onTap: () => widget._onPressed(widget.restaurant!),
      splashColor: Colors.blue.withAlpha(30),
      child: Container(
        height: 250,
        child: Column(
          children: <Widget>[
            Expanded(
              child: LayoutBuilder(
                builder: (con, bc) {
                  return SizedBox(
                    width: bc.maxWidth,
                    height: bc.maxHeight,
                    child: Hero(
                      tag: widget.restaurant!.id!,
                      child: Image.network(
                        widget.restaurant!.photo,
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          widget.restaurant!.name,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      Text(
                        '\$' * widget.restaurant!.price,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, (kIsWeb ? 0 : 2), 0, 4),
                    alignment: Alignment.bottomLeft,
                    child: StarRating(
                      rating: widget.restaurant!.avgRating,
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      '${widget.restaurant!.category} ● ${widget.restaurant!.city}',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
