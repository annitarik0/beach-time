import 'package:flutter/widgets.dart';
import '../theme/ph_icons.dart';

/// What the user wants to do at the beach. Each activity weighs the
/// conditions differently (a surfer wants waves, a swimmer does not).
enum Activity { swim, surf, sunbathe }

extension ActivityX on Activity {
  String get label => switch (this) {
        Activity.swim => 'Swim',
        Activity.surf => 'Surf',
        Activity.sunbathe => 'Chill',
      };

  String get verb => switch (this) {
        Activity.swim => 'swim',
        Activity.surf => 'surf',
        Activity.sunbathe => 'lie in the sun',
      };

  IconData get icon => switch (this) {
        Activity.swim => PhIcons.personSimpleSwim,
        Activity.surf => PhIcons.waves,
        Activity.sunbathe => PhIcons.sunHorizon,
      };
}
