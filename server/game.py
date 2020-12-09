#!/usr/bin/env python
# coding: utf-8

import random

import pygame
import json
from player import Player
from npc import NPC
from bullet import Bullet
from world import World

class Game:
    def __init__(self):
        #self.successes, self.failures = pygame.init()
        self.clock = pygame.time.Clock()
        self.players = {}
        self.npcs = {}
        self.bullets = {}
        self.npc_id = 0
        self.bullet_id = 0
        self.minX = 0
        self.maxX = 60000
        self.minY = 0
        self.maxY = 2000
        self.world = World("japaneseVillage")
        
    def add_player(self, id):
        self.players[id] = Player(id, 0.0, 0.0, 300, 300, "elf")
        return self.players[id]
        
    def add_npc(self):
        x = random.randint(self.minX, self.maxX)
        y = random.randint(self.minY, self.maxY)
        self.npcs[self.npc_id] = NPC(self.npc_id, x, y, 50, 50, "priest")
        self.npc_id += 1

    def add_bullet(self, playerId, dest_x, dest_y):
        self.bullets[self.bullet_id] = Bullet(self.bullet_id, playerId, self.players[playerId].rect.x, self.players[playerId].rect.y, dest_x, dest_y, "standard")
        self.bullet_id += 1
        
    def update(self):
        rand = random.randint(0, 300)
        #every frame there is a chance of 1/300 for adding a new npc
        if(rand == 150 and len(self.npcs) < 10):
            self.add_npc()

        #remove dead players and update the others
        self.players = dict([val for val in self.players.items() if val[1].lifestate != 0])
        [val.update(self.world) for val in self.players.values()]
        
        #remove dead npcs and update the others
        self.npcs = dict([val for val in self.npcs.items() if val[1].lifestate != 0])
        [npc.update(self.world) for npc in self.npcs.values()]

        #remove dead bullets and update the others
        self.bullets = dict([val for val in self.bullets.items() if val[1].lifestate != 0])
        [val.update(self.world) for val in self.bullets.values()]

        self.check_bullets_collissions()

    def set_destination(self, id, x, y):
        self.players[id].set_destination(x,y)

    def check_bullets_collissions(self):
        hasHit = False
        for bullet in self.bullets.values():
            for player in self.players.values():
                if player.rect.colliderect(bullet.rect) and bullet.playerId != player.id:
                    player.health -= bullet.damage
                    bullet.lifestate = 0
                    hasHit = True
                    break
            if not hasHit:
                for npc in self.npcs.values():
                    if npc.rect.colliderect(bullet.rect):
                        npc.health -= bullet.damage
                        bullet.lifestate = 0
                        hasHit = True
                        break

            
    def return_state(self):
        players = {}
        npcs = {}
        bullets = {}
        world = self.world.toJson()
        for key in self.players:
            players[key] = self.players[key].toJson()
        for key in self.npcs:
            npcs[key] = self.npcs[key].toJson()
        for key in self.bullets:
            bullets[key] = self.bullets[key].toJson()
        state = {"players" : players, "npcs": npcs, "bullets": bullets, "world": world }
        return state