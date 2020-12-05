import 'AnimatedEntity..dart';
import 'entityData.dart';

class Player extends AnimatedEntity {
  String _type;
  double x, y;
  int id;
  int _dir;

  //A player and an opponent use the same sprite images
  Player(this.id, this.x, this.y, this._type, this._dir)
      : super(
            entityData['opponents'][_type]["imgUrl"],
            entityData['opponents'][_type]["txtWidth"],
            entityData['opponents'][_type]["txtHeight"],
            entityData['opponents'][_type]["cols"],
            entityData['opponents'][_type]["rows"],
            x,
            y,
            _dir);

  factory Player.fromJson(Map<String, dynamic> json) => Player(json["id"],
      json["x"].toDouble(), json["y"].toDouble(), json["type"], json["dir"]);

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
        "id": id,
        "type": _type,
      };
}
