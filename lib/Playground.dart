import 'dart:convert';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:socketgame/entities/Background.dart';
import 'package:socketgame/entities/Character.dart';
import 'package:socketgame/entities/NPC.dart';
import 'package:socketgame/views/utils/SizeHolder.dart';

import 'entities/Bullet.dart';
import 'entities/Entity.dart';
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
    if (_bg != null) {
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
    List<Entity> entities = [...players, ...npcs, ...bullets];
    if (_bg != null) {
      _bg.render(canvas);
      entities.addAll(_bg.things);
    }
    if (_char != null) entities.add(_char);

    entities.sort((a, b) => compareEntities(a, b));

    //TODO: there always needs to be a character, we have to create one with the playground!
    if (_char != null) {
      entities.forEach((element) {
        element.render(canvas);
      });
      _char.renderInterface(canvas);
    }
  }

  int compareEntities(Entity a, Entity b) {
    double compA, compB;

    if (a.activeEntity != null) {
      compA = a.activeEntity.y + a.activeEntity.height;
    } else if (a.animatedEntity != null) {
      compA = a.animatedEntity.y + a.animatedEntity.height;
    } else {
      compA = 0;
    }
    if (b.activeEntity != null) {
      compB = b.activeEntity.y + b.activeEntity.height;
    } else if (b.animatedEntity != null) {
      compB = b.animatedEntity.y + b.animatedEntity.height;
    } else {
      compB = 0;
    }

    return compA.compareTo(compB);
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

  void updateState(String state) {
    Map<String, dynamic> nextState = jsonDecode(state);
    this.gametime = nextState["gametime"].toDouble();

    //Get all the players in the list from the server
    var nextPlayers = nextState["gamestate"]["players"];

    //Only do something if the player itself is in the player list
    if (nextPlayers != null && nextPlayers[_char.id.toString()] != null) {
      Map<String, dynamic> nextCharState = nextPlayers[_char.id.toString()];

      //If there is no playing char yet we create one
      // if (this._char == null) {
      //   //this._char = Character.fromJson(nextCharState);
      //   //this._char.resize();
      //   this._bg = Background(nextWorld, nextCharState);
      //   this._bg.resize();
      // } else {
      this._char.updateState(nextCharState);
      this._bg.updateState(nextCharState, this.gametime);

      List<Player> updatedPlayers = [];
      for (var nextPlState in nextPlayers.values) {
        bool isNewPlayer = true;
        this.players.forEach((previousPlayer) {
          if (nextPlState["id"] != _char.id &&
              previousPlayer.id == nextPlState["id"]) {
            previousPlayer.updateState(nextCharState, nextPlState, gametime);
            updatedPlayers.add(previousPlayer);
            isNewPlayer = false;
          }
        });
        if (nextPlState["id"] != _char.id && isNewPlayer) {
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
              previousNpc.updateState(nextCharState, nextNpcState, gametime);
              updatedNpcs.add(previousNpc);
              isNewNpc = false;
            }
          });
          if (isNewNpc) {
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
              previousBullet.updateState(
                  nextCharState, nextBulletState, gametime);
              updatedBullets.add(previousBullet);
              isNewBullet = false;
            }
          });
          if (isNewBullet) {
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
          charOffsetX -
          (nextCharState["x"] * screenSize.width / 20000),
      "y": (nextPlState["y"] * screenSize.height / 10000) +
          charOffsetY -
          (nextCharState["y"] * screenSize.height / 10000),
      "dir": nextPlState["dir"],
      "health": nextPlState["health"],
      "maxHealth": nextPlState["maxHealth"],
      "duration": DateTime.now().millisecondsSinceEpoch
    };
    playerToAdd.resize();
    return playerToAdd;
  }

  NPC addNPC(var nextNpcState, var nextCharState) {
    NPC npcToAdd = NPC.fromJson(nextNpcState);
    npcToAdd.initialState = {
      "x": (nextNpcState["x"] * screenSize.width / 20000) +
          charOffsetX -
          (nextCharState["x"] * screenSize.width / 20000),
      "y": (nextNpcState["y"] * screenSize.height / 10000) +
          charOffsetY -
          (nextCharState["y"] * screenSize.height / 10000),
      "dir": nextNpcState["dir"],
      "health": nextNpcState["health"],
      "maxHealth": nextNpcState["maxHealth"],
      "duration": DateTime.now().millisecondsSinceEpoch
    };
    npcToAdd.resize();
    return npcToAdd;
  }

  Bullet addBullet(var nextBulletState, var nextCharState) {
    Bullet bulletToAdd = Bullet.fromJson(nextBulletState);
    bulletToAdd.initialState = {
      "x": (nextBulletState["x"] * screenSize.width / 20000) +
          charOffsetX -
          (nextCharState["x"] * screenSize.width / 20000),
      "y": (nextBulletState["y"] * screenSize.height / 10000) +
          charOffsetY -
          (nextCharState["y"] * screenSize.height / 10000),
      "duration": DateTime.now().millisecondsSinceEpoch
    };
    bulletToAdd.resize();
    return bulletToAdd;
  }

  void init(String updateString) {
    var data = jsonDecode(updateString);
    this._char = Character.fromJson(data["player"]);
    this._bg = Background(data["gamestate"]["world"], data["player"]);
    this._char.resize();
    this._bg.resize();
  }

  bool isInitialized() {
    return (_char != null && _bg != null);
  }
}
