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

        self.worlds = [World("japaneseVillage"), World("insideHouse"), World("beach")]
        
    def add_player(self, id):
        world_for_player = random.randint(0, 2)
        player = self.worlds[world_for_player].add_player(id)
        self.players[id] = world_for_player

        return player
        

    def add_bullet(self, playerId, dest_x, dest_y):
        self.worlds[self.players[playerId]].add_bullet(playerId, dest_x, dest_y)

    def change_world_for_player(self, player_id):
        self.worlds[self.players[player_id]].remove_player(player_id)
        world_dest = random.randint(0, 2)
        # if (destination == "insideHouse"):
        #     world_dest = 1
        # elif (destination == "beack"):
        #     world_dest = 2

        player = self.worlds[world_dest].add_player(player_id)
        self.players[player_id] = world_dest
        return player

    def update(self):
        [val.update() for val in self.worlds]

    def set_destination(self, id, x, y):
        self.worlds[self.players[id]].set_destination(id,x,y)

            
    def return_world_for_player(self, id):
        return self.worlds[self.players[id]].return_state()
