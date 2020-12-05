import 'package:socketgame/entities/entityData.dart';

import 'AnimatedEntity..dart';

class NPC extends AnimatedEntity {
  NPC(_type, double x, double y, int dir)
      : super(
            entityData['npcs'][_type]["imgUrl"],
            entityData['npcs'][_type]["txtWidth"],
            entityData['npcs'][_type]["txtHeight"],
            entityData['npcs'][_type]["cols"],
            entityData['npcs'][_type]["rows"],
            x,
            y,
            dir);
}
