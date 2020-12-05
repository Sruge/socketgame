#!/usr/bin/env python
# coding: utf-8

import random

import pygame
import json
from player import Player
from npc import NPC

class Game:
    def __init__(self):
        #self.successes, self.failures = pygame.init()
        self.clock = pygame.time.Clock()
        self.players = {}
        self.npcs = {}
        self.bullets = {}
        self.npc_id = 0
        self.minX = 0
        self.maxX = 1000
        self.minY = 0
        self.maxY = 500
        
    def add_player(self, id):
        self.players[id] = Player(id, 10.0, 10.0, 300, 300, "elf")
        
    def add_npc(self):
        x = random.randint(self.minX, self.maxX)
        y = random.randint(self.minY, self.maxY)
        self.npcs[self.npc_id] = NPC(self.npc_id, x, y, 50, 50, "priest")
        self.npc_id += 1
        
    def update(self):
        rand = random.randint(0, 200)
        if(rand == 150 and len(self.npcs) < 10):
            self.add_npc()
        for key in self.players:
            self.players[key].update(2)
        for key in self.npcs:
            self.npcs[key].update(2)

    def set_destination(self, id, x, y):
        self.players[id].set_destination(x,y)
            
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