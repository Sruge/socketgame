
import pygame
import json
import utils

import random

from player import Player
from npc import NPC
from bullet import Bullet

class World:
    def __init__(self, world_type):
        self.world_data = utils.get_world_data(world_type)
        self.bg = self.world_data[0]
        self.width = self.world_data[1]
        self.height = self.world_data[2]
        self.rect = pygame.Rect((0,0),(self.world_data[1],self.world_data[2]))
        self.things = [thing for thing in utils.get_things_for_world(world_type)]
        self.players = {}
        self.npcs = {}
        self.bullets = {}
        self.doors = [door for door in utils.get_doors_for_world(world_type)]
        self.npc_id = 0
        self.bullet_id = 0


    def add_player(self, id):
        player = Player(id, 0.0, 0.0, 300, 300, "elf")
        self.players[id] = player
        return player

    def remove_player(self, id):
        del self.players[id]
        
    def add_npc(self):
        x = random.randint(0, self.rect.width)
        y = random.randint(0, self.rect.height)
        self.npcs[self.npc_id] = NPC(self.npc_id, x, y, 50, 50, "priest")
        self.npc_id += 1

    def add_bullet(self, playerId, dest_x, dest_y):
        self.bullets[self.bullet_id] = Bullet(self.bullet_id, playerId, self.players[playerId].rect.x, self.players[playerId].rect.y, dest_x, dest_y, "standard")
        self.bullets[self.bullet_id].update(self)
        self.bullet_id += 1
        
    def update(self):
        rand = random.randint(0, 300)
        #every frame there is a chance of 1/300 for adding a new npc
        if(rand == 150 and len(self.npcs) < 10):
            self.add_npc()

        #remove dead players and update the others
        self.players = dict([val for val in self.players.items() if val[1].lifestate != 0])
        [val.update(self) for val in self.players.values()]
        
        #remove dead npcs and update the others
        self.npcs = dict([val for val in self.npcs.items() if val[1].lifestate != 0])
        [npc.update(self) for npc in self.npcs.values()]

        #remove dead bullets and update the others
        self.bullets = dict([val for val in self.bullets.items() if val[1].lifestate != 0])
        [val.update(self) for val in self.bullets.values()]

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
        for key in self.players:
            players[key] = self.players[key].toJson()
        for key in self.npcs:
            npcs[key] = self.npcs[key].toJson()
        for key in self.bullets:
            bullets[key] = self.bullets[key].toJson()
        state = {"players" : players, "npcs": npcs, "bullets": bullets, "world": self.toJson() }
        return state
        
                
    def toJson(self):
        return {"bg":self.bg,"x":self.rect.x, "y":self.rect.y, "width":self.rect.width, "height":self.rect.height, "things":[thing.toJson() for thing in self.things ], "doors":[door.toJson() for door in self.doors ]}