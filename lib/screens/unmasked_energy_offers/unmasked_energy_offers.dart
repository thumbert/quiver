library screens.unmasked_energy_offers.unmasked_energy_offers;

import 'package:date/date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/widgets.dart' hide Interval;
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/unmasked_energy_offers.dart';
import 'package:flutter_quiver/screens/unmasked_energy_offers/unmasked_energy_offers_ui.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart';

class UnmaskedEnergyOffers extends StatefulWidget {
  const UnmaskedEnergyOffers({Key? key}) : super(key: key);

  @override
  _UnmaskedEnergyOffersState createState() => _UnmaskedEnergyOffersState();
}

class _UnmaskedEnergyOffersState extends State<UnmaskedEnergyOffers> {
  // final term = Term.parse(Month.current().subtract(4).toString(), UTC);
  final term = Term.parse('Apr18', getLocation('America/New_York'));

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => TermModel(term: term)),
      ChangeNotifierProvider(create: (context) => UnmaskedEnergyOffersModel()),
    ], child: const UnmaskedEnergyOffersUi());
  }
}
