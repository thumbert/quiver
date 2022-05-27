library screens.common.bucket;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/bucket_model.dart';
import 'package:provider/provider.dart';

class Bucket extends StatefulWidget {
  const Bucket({Key? key}) : super(key: key);

  @override
  _BucketState createState() => _BucketState();
}

class _BucketState extends State<Bucket> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<BucketModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 80,
          child: Text(
            'Bucket',
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(
          width: 150,
          child: DropdownButtonFormField(
            value: model.bucket,
            icon: const Icon(Icons.expand_more),
            hint: const Text('Filter'),
            decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor))),
            elevation: 16,
            onChanged: (String? newValue) {
              setState(() {
                model.bucket = newValue!;
              });
            },
            items: BucketMixin.allowedBuckets
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ),
      ],
    );
  }
}
