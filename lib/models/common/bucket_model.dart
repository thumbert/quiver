library models.bucket_model;

import 'package:elec/elec.dart';
import 'package:flutter/material.dart';

mixin BucketMixin on ChangeNotifier {
  late String _bucket;

  static List<String> allowedBuckets = Bucket.buckets.keys.toList();

  set bucket(String value) {
    if (allowedBuckets.contains(value)) {
      _bucket = value;
      notifyListeners();
    }
  }

  String get bucket => _bucket;
}

class BucketModel extends ChangeNotifier with BucketMixin {
  BucketModel();

  void init(String value, {List<String>? allowedBuckets}) {
    _bucket = value;
    if (allowedBuckets != null) {
      BucketMixin.allowedBuckets = allowedBuckets;
    }
  }
}
