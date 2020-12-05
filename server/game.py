#!/usr/bin/env python
# coding: utf-8


import pygame
import json
from player import Player

class Game:
    def __init__(self):
        #self.successes, self.failures = pygame.init()
        self.clock = pygame.time.Clock()
        self.players = {}
        
    def add_player(self, id):
        self.players[id] = Player(id, 10.0, 10.0, "elf")
        
    def update_players(self):
        for key in self.players:
            self.players[key].move(2)

    def set_destination(self, id, x, y):
        self.players[id].set_destination(x,y)
            
    def return_state(self):
        state = {}
        for key in self.players:
            state[key] = self.players[key].toJson()
        return state