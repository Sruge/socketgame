import 'AnimatedEntity..dart';
import 'entityData.dart';

class NPC extends AnimatedEntity {
  String _type;
  double x, y;
  int id;
  int _dir;

  //A player and an opponent use the same sprite images
  NPC(this.id, this.x, this.y, this._type, this._dir)
      : super(
            entityData['npcs'][_type]["imgUrl"],
            entityData['npcs'][_type]["txtWidth"],
            entityData['npcs'][_type]["txtHeight"],
            entityData['npcs'][_type]["cols"],
            entityData['npcs'][_type]["rows"],
            x,
            y,
            _dir);

  factory NPC.fromJson(Map<String, dynamic> json) => NPC(json["id"],
      json["x"].toDouble(), json["y"].toDouble(), json["type"], json["dir"]);

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
        "id": id,
        "type": _type,
      };
}
