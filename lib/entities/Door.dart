import 'package:flutter/gestures.dart';
import 'package:socketgame/MMOGame.dart';
import 'package:socketgame/entities/BaseEntity.dart';
import 'package:socketgame/entities/interface/CharacterMode.dart';

import 'entityData.dart';

class Door extends BaseEntity {
  int id;
  String destination;

  //A player and an opponent use the same sprite images
  Door(this.id, String _type, destination)
      : super(entityData['doors'][_type]["imgUrl"], 100, 200);

  void onTapDown(TapDownDetails details) {
    if (activeEntity.toRect().contains(details.globalPosition)) {
      mmoGame.addToSocket(CharacterMode.WorldChange.toString(), 0, 0);
    }
  }

  factory Door.fromJson(Map<String, dynamic> json) =>
      Door(json["id"], json["type"], json["destination"]);
}
