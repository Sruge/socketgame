import 'AnimatedEntity..dart';
import 'entityData.dart';

class Opponent extends AnimatedEntity {
  Opponent(_type, double x, double y, int dir)
      : super(
            entityData['opponents'][_type]["imgUrl"],
            entityData['opponents'][_type]["txtWidth"],
            entityData['opponents'][_type]["txtHeight"],
            entityData['opponents'][_type]["cols"],
            entityData['opponents'][_type]["rows"],
            x,
            y,
            dir);
}
