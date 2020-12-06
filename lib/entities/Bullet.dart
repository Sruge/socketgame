import 'package:socketgame/entities/BaseEntity.dart';

import 'entityData.dart';

class Bullet extends BaseEntity {
  String _type;
  double x, y;
  int id;

  //A player and an opponent use the same sprite images
  Bullet(this.id, this.x, this.y, this._type)
      : super(
          entityData['bullets'][_type]["imgUrl"],
          entityData['bullets'][_type]["width"],
          entityData['bullets'][_type]["height"],
          x,
          y,
        );

  factory Bullet.fromJson(Map<String, dynamic> json) => Bullet(
      json["id"], json["x"].toDouble(), json["y"].toDouble(), json["type"]);

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
        "id": id,
        "type": _type,
      };
}
