import 'dart:convert';
import 'dart:ui';

import 'package:socketgame/entities/Background.dart';
import 'package:socketgame/entities/Character.dart';

import 'entities/Player.dart';

Playground gamestateFromJson(String str) =>
    Playground.fromJson(json.decode(str));

String gamestateToJson(Playground data) => json.encode(data.toJson());

class Playground {
  Background _bg;
  double serverT;
  double gametime;
  List<Player> players;
  Character _char;

  Playground({
    this.players,
    this.gametime,
  });

  factory Playground.fromJson(Map<String, dynamic> json) => Playground(
        gametime: json["gametime"],
        players:
            List<Player>.from(json["players"].map((x) => Player.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "gametime": gametime,
        "players": List<dynamic>.from(players.map((x) => x.toJson())),
      };

  void update(double t) {
    if (_char != null) {
      _char.update(t, serverT);
      _bg.update(t, serverT);
    }
    players.forEach((element) {
      element.update(t, serverT);
    });
  }

  void render(Canvas canvas) {
    if (_char != null) {
      _bg.render(canvas);
      _char.render(canvas);
    }
    players.forEach((element) {
      element.render(canvas);
    });
  }

  void resize() {
    players.forEach((element) {
      element.resize();
    });
  }

  void updateState(String state, int id) {
    Map<String, dynamic> nextState = jsonDecode(state);
    this.serverT = nextState["gametime"].toDouble() - this.gametime;
    this.gametime = nextState["gametime"].toDouble();

    //Get all the players in the list from the server
    var nextPlayers = nextState["players"];

    //Only do something if the player itself is in the player list
    if (nextPlayers != null && nextPlayers[id.toString()] != null) {
      Map<String, dynamic> nextCharState = nextPlayers[id.toString()];

      //If there is no playing char yet we create one
      if (this._char == null) {
        this._char = Character.fromJson(nextCharState);
        this._char.resize();
        this._bg =
            Background('bg2.png', nextCharState["x"], nextCharState["y"]);
        this._bg.resize();
      } else {
        this._char.updateState(nextCharState);
        this._bg.updateState(nextCharState);
      }

      for (var nextPlState in nextPlayers.values) {
        var isNewPlayer = true;
        this.players.forEach((previousPlayer) {
          if (nextPlState["id"] != id &&
              previousPlayer.id == nextPlState["id"]) {
            previousPlayer.updateState(nextCharState, nextPlState);
            isNewPlayer = false;
          }
        });
        if (nextPlState["id"] != id && isNewPlayer) {
          print(
              "New Player since last state update: " + nextPlState.toString());
          Player playerToAdd = Player.fromJson(nextPlState);
          playerToAdd.resize();
          this.players.add(playerToAdd);
        }
      }
    }
  }
}
