library error404;

import 'package:flutter/material.dart';

class Error404 extends StatelessWidget {
  const Error404({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oops!')),
      body: Column(children: [
        const SizedBox(height: 128),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 400,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Page not found',
                      style: TextStyle(
                          color: Colors.redAccent,
                          // fontFamily: 'Tangerine',
                          fontSize: 48,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 48),
                    SizedBox(height: 24),
                    Text('The link you clicked has not been implemented yet',
                        style: TextStyle(fontSize: 20, color: Colors.brown)),
                  ]),
            ),
            const SizedBox(width: 20),
            Image.asset('images/robot.png'),
          ],
        ),
      ]),
    );
  }
}
