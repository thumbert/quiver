library models.bucket_model;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

class BucketModel extends ChangeNotifier {
  BucketModel({required String bucket, List<String>? allowedBuckets}) {
    _bucket = bucket;
    if (allowedBuckets != null) {
      this.allowedBuckets = allowedBuckets;
    }
  }

  late String _bucket;

  List<String> allowedBuckets = <String>[
    '7x24',
    'Peak',
    'Offpeak',
  ];

  set bucket(String bucket) {
    _bucket = bucket;
    notifyListeners();
  }

  String get bucket => _bucket;
}
