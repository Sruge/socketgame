#!/usr/bin/env python
# coding: utf-8

import random

import pygame
import json
from player import Player
from npc import NPC
from bullet import Bullet

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
        
    def add_player(self, id):
        self.players[id] = Player(id, 10.0, 10.0, 300, 300, "elf")
        
    def add_npc(self):
        x = random.randint(self.minX, self.maxX)
        y = random.randint(self.minY, self.maxY)
        self.npcs[self.npc_id] = NPC(self.npc_id, x, y, 50, 50, "priest")
        self.npc_id += 1

    def add_bullet(self, playerId, dest_x, dest_y):
        self.bullets[self.bullet_id] = Bullet(self.bullet_id, self.players[playerId].rect.x, self.players[playerId].rect.y, dest_x, dest_y, "standard")
        self.bullet_id += 1
        
    def update(self):
        rand = random.randint(0, 200)
        #every frame there is a chance of 1/150 for adding a new npc
        if(rand == 150 and len(self.npcs) < 10):
            self.add_npc()

        #remove dead players and update the others
        self.players = dict([val for val in self.players.items() if val[0] != 0])
        [val.update() for val in self.players.values()]
        
        #remove dead npcs and update the others
        self.npcs = dict([val for val in self.npcs.items() if val[0] != 0])
        [npc.update() for npc in self.npcs.values()]

        #remove dead bullets and update the others
        self.bullets = dict([val for val in self.bullets.items() if val[0] != 0])
        [val.update() for val in self.bullets.values()]

        self.check_bullets_collissions()

    def set_destination(self, id, x, y):
        self.players[id].set_destination(x,y)

    def check_bullets_collissions(self):
        for bullet in self.bullets.items():
            print(bullet[1].rect.center)
            hitPlayer = bullet[1].rect.collidelist([player[1].rect for player in self.players.items()])

            
    def return_state(self):
        players = {}
        npcs = {}
        bullets = {}
        for key in self.players:
            players[key] = self.players[key].toJson()
        for key in self.npcs:
            npcs[key] = self.npcs[key].toJson()
        for key in self.bullets:
            bullets[key] = self.bullets[key].toJson()
        state = {"players" : players, "npcs": npcs, "bullets": bullets}
        return state