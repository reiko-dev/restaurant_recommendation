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

// This is called "ratings" in the backend.
class Review {
  final String? id;
  final String userId;
  final double rating;
  final String text;
  final String userName;
  final Timestamp? timestamp;

  final DocumentReference? reference;

  Review.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot.id,
        rating = (snapshot.data() as Map)['rating'].toDouble(),
        text = (snapshot.data() as Map)['text'],
        userName = (snapshot.data() as Map)['userName'],
        userId = (snapshot.data() as Map)['userId'],
        timestamp = (snapshot.data() as Map)['timestamp'],
        reference = snapshot.reference;

  Review.fromUserInput({
    required this.rating,
    required this.text,
    required this.userName,
    required this.userId,
  })  : id = null,
        timestamp = null,
        reference = null;

  factory Review.random({required String userName, required String userId}) {
    final rating = Random().nextInt(4) + 1;
    final review = getRandomReviewText(rating);
    return Review.fromUserInput(
      rating: rating.toDouble(),
      text: review,
      userName: userName,
      userId: userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rating': rating,
      'text': text,
      'userName': userName,
      'userId': userId,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return '(id: $id, userId: $userId, rating: $rating, text: $text)';
  }
}
