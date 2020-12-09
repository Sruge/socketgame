import 'package:socketgame/entities/BaseEntity.dart';
import 'package:socketgame/views/utils/SizeHolder.dart';

import 'entityData.dart';

class Thing extends BaseEntity {
  int id;

  Thing(this.id, _type, int width, int height)
      : super(
          entityData['things'][_type]["imgUrl"],
          width * scaledScreenSizeWidth,
          height * scaledScreenSizeHeight,
        );

  void updatePosition(double velX, double velY) {
    activeEntity.x += velX;
    activeEntity.y += velY;
  }

  factory Thing.fromJson(Map<String, dynamic> json) =>
      Thing(json["id"], json["type"], json["width"], json["height"]);
}
