import 'package:socketgame/entities/entityData.dart';

import 'AnimatedEntity..dart';

class Building extends AnimatedEntity {
  String _type;
  Building(this._type, double x, double y, int dir)
      : super(
            entityData['buildings'][_type]["imgUrl"],
            entityData['buildings'][_type]["txtWidth"],
            entityData['buildings'][_type]["txtHeight"],
            entityData['buildings'][_type]["cols"],
            entityData['buildings'][_type]["rows"],
            x,
            y,
            dir);
}
