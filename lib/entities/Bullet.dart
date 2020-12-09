import 'package:socketgame/entities/BaseEntity.dart';

import 'entityData.dart';

class Bullet extends BaseEntity {
  int id;

  //A player and an opponent use the same sprite images
  Bullet(this.id, _type)
      : super(
          entityData['bullets'][_type]["imgUrl"],
          entityData['bullets'][_type]["width"],
          entityData['bullets'][_type]["height"],
        );

  factory Bullet.fromJson(Map<String, dynamic> json) =>
      Bullet(json["id"], json["type"]);
}
