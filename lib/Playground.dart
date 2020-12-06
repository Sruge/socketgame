import 'dart:convert';
import 'dart:ui';

import 'package:socketgame/entities/Background.dart';
import 'package:socketgame/entities/Character.dart';
import 'package:socketgame/entities/NPC.dart';
import 'package:socketgame/views/utils/SizeHolder.dart';

import 'entities/Player.dart';

class Playground {
  Background _bg;
  double serverT;
  double gametime;
  List<Player> players;
  List<NPC> npcs;
  Character _char;

  Playground({
    this.players,
    this.gametime,
  }) {
    npcs = [];
  }

  void update(double t) {
    if (_char != null) {
      _char.update(t, serverT);
      _bg.update(t, serverT);

      players.forEach((element) {
        element.update(t, serverT);
      });
      npcs.forEach((element) {
        element.update(t, serverT);
      });
    }
  }

  void render(Canvas canvas) {
    if (_char != null) {
      _bg.render(canvas);
      _char.render(canvas);

      players.forEach((element) {
        element.render(canvas);
      });
      npcs.forEach((element) {
        element.render(canvas);
      });
    }
  }

  void resize() {
    if (_char != null) {
      players.forEach((element) {
        element.resize();
      });
      npcs.forEach((element) {
        element.resize();
      });
    }
  }

  void updateState(String state, int id) {
    Map<String, dynamic> nextState = jsonDecode(state);
    this.serverT = nextState["gametime"].toDouble() - this.gametime;
    this.gametime = nextState["gametime"].toDouble();

    //Get all the players in the list from the server
    var nextPlayers = nextState["gamestate"]["players"];

    //Only do something if the player itself is in the player list
    if (nextPlayers != null && nextPlayers[id.toString()] != null) {
      Map<String, dynamic> nextCharState = nextPlayers[id.toString()];

      //If there is no playing char yet we create one
      if (this._char == null) {
        this._char = Character.fromJson(nextCharState);
        this._char.resize();
        this._bg = Background('bg2.png', nextCharState["x"].toDouble(),
            nextCharState["y"].toDouble());
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
          addPlayer(nextPlState, nextCharState);
        }
      }

      var nextNpcs = nextState["gamestate"]["npcs"];
      if (nextNpcs != null) {
        for (var nextNpcState in nextNpcs.values) {
          var isNewNpc = true;
          this.npcs.forEach((previousNpc) {
            if (nextNpcState["id"] != id &&
                previousNpc.id == nextNpcState["id"]) {
              previousNpc.updateState(nextCharState, nextNpcState);
              isNewNpc = false;
            }
          });
          if (isNewNpc) {
            print(
                "New NPC since last state update: " + nextNpcState.toString());
            addNPC(nextNpcState, nextCharState);
          }
        }
      }
    }
  }

  void addPlayer(var nextPlState, var nextCharState) {
    Player playerToAdd = Player.fromJson(nextPlState);
    playerToAdd.initialState = {
      "x": (nextPlState["x"] * screenSize.width / 20000) +
          (screenSize.width - baseAnimationWidth()) / 2 -
          (nextCharState["x"] * screenSize.width / 20000),
      "y": (nextPlState["y"] * screenSize.height / 10000) +
          (screenSize.height - baseAnimationHeight()) / 2 -
          (nextCharState["y"] * screenSize.height / 10000),
      "dir": nextPlState["dir"],
      "duration": DateTime.now().millisecondsSinceEpoch
    };
    playerToAdd.resize();
    this.players.add(playerToAdd);
  }

  void addNPC(var nextNpcState, var nextCharState) {
    NPC npcToAdd = NPC.fromJson(nextNpcState);
    npcToAdd.initialState = {
      "x": (nextNpcState["x"] * screenSize.width / 20000) +
          (screenSize.width - baseAnimationWidth()) / 2 -
          (nextCharState["x"] * screenSize.width / 20000),
      "y": (nextNpcState["y"] * screenSize.height / 10000) +
          (screenSize.height - baseAnimationHeight()) / 2 -
          (nextCharState["y"] * screenSize.height / 10000),
      "dir": nextNpcState["dir"],
      "duration": DateTime.now().millisecondsSinceEpoch
    };
    npcToAdd.resize();
    this.npcs.add(npcToAdd);
  }
}
