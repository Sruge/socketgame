import 'dart:convert';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:socketgame/entities/Background.dart';
import 'package:socketgame/entities/Character.dart';
import 'package:socketgame/entities/NPC.dart';
import 'package:socketgame/views/utils/SizeHolder.dart';

import 'entities/Bullet.dart';
import 'entities/Player.dart';

class Playground {
  Background _bg;
  double serverT;
  double gametime;
  List<Player> players;
  List<NPC> npcs;
  List<Bullet> bullets;
  Character _char;

  Playground({
    this.players,
    this.gametime,
  }) {
    npcs = [];
    bullets = [];
  }

  void onTapDown(TapDownDetails details) {
    if (_char != null) {
      _char.onTapDown(details);
    }
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
      bullets.forEach((element) {
        element.update(t, serverT);
      });
    }
  }

  void render(Canvas canvas) {
    if (_char != null) {
      _bg.render(canvas);

      bullets.forEach((element) {
        element.render(canvas, true);
      });

      //render the entities in the upper half first so they are behind the char
      players.forEach((element) {
        element.render(canvas, true);
      });
      npcs.forEach((element) {
        element.render(canvas, true);
      });

      //render the char in the middle
      _char.renderChar(canvas);
      //render the entities in the lower half after the char so they are in front
      players.forEach((element) {
        element.render(canvas, false);
      });
      npcs.forEach((element) {
        element.render(canvas, false);
      });

      //On top of all the players and enemys we render the bullets
      bullets.forEach((element) {
        element.render(canvas, true);
      });
      //At the very end render the interface
      _char.renderInterface(canvas);
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
      bullets.forEach((element) {
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
      List<Player> updatedPlayers = [];
      for (var nextPlState in nextPlayers.values) {
        bool isNewPlayer = true;
        this.players.forEach((previousPlayer) {
          if (nextPlState["id"] != id &&
              previousPlayer.id == nextPlState["id"]) {
            previousPlayer.updateState(nextCharState, nextPlState);
            updatedPlayers.add(previousPlayer);
            isNewPlayer = false;
          }
        });
        if (nextPlState["id"] != id && isNewPlayer) {
          print(
              "New Player since last state update: " + nextPlState.toString());
          updatedPlayers.add(addPlayer(nextPlState, nextCharState));
        }
      }
      players = updatedPlayers;

      var nextNpcs = nextState["gamestate"]["npcs"];
      List<NPC> updatedNpcs = [];
      if (nextNpcs != null) {
        for (var nextNpcState in nextNpcs.values) {
          bool isNewNpc = true;
          this.npcs.forEach((previousNpc) {
            if (previousNpc.id == nextNpcState["id"]) {
              previousNpc.updateState(nextCharState, nextNpcState);
              updatedNpcs.add(previousNpc);
              isNewNpc = false;
            }
          });
          if (isNewNpc) {
            print(
                "New NPC since last state update: " + nextNpcState.toString());
            updatedNpcs.add(addNPC(nextNpcState, nextCharState));
          }
        }
      }
      npcs = updatedNpcs;

      var nextBullets = nextState["gamestate"]["bullets"];
      List<Bullet> updatedBullets = [];
      if (nextBullets != null) {
        for (var nextBulletState in nextBullets.values) {
          bool isNewBullet = true;
          this.bullets.forEach((previousBullet) {
            if (previousBullet.id == nextBulletState["id"]) {
              previousBullet.updateState(nextCharState, nextBulletState);
              updatedBullets.add(previousBullet);
              isNewBullet = false;
            }
          });
          if (isNewBullet) {
            print("New Bullet since last state update: " +
                nextBulletState.toString());
            updatedBullets.add(addBullet(nextBulletState, nextCharState));
          }
        }
      }
      bullets = updatedBullets;
    }
  }

  Player addPlayer(var nextPlState, var nextCharState) {
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
    return playerToAdd;
  }

  NPC addNPC(var nextNpcState, var nextCharState) {
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
    return npcToAdd;
  }

  Bullet addBullet(var nextBulletState, var nextCharState) {
    Bullet bulletToAdd = Bullet.fromJson(nextBulletState);
    bulletToAdd.initialState = {
      "x": (nextBulletState["x"] * screenSize.width / 20000) +
          (screenSize.width - screenSize.width * 0.01) / 2 -
          (nextCharState["x"] * screenSize.width / 20000),
      "y": (nextBulletState["y"] * screenSize.height / 10000) +
          (screenSize.height - screenSize.height * 0.02) / 2 -
          (nextCharState["y"] * screenSize.height / 10000),
      "duration": DateTime.now().millisecondsSinceEpoch
    };
    bulletToAdd.resize();
    return bulletToAdd;
  }
}
