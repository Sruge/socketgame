
import pygame
import json
import utils

class World:
    def __init__(self, world_type):
        self.world_data = utils.get_world_data(world_type)
        self.bg = self.world_data[0]
        self.width = self.world_data[1]
        self.height = self.world_data[2]
        self.rect = pygame.Rect((0,0),(self.world_data[1],self.world_data[2]))
        self.things = [thing for thing in utils.get_things_for_world(world_type)]
        
                
    def toJson(self):
        return {"bg":self.bg,"x":self.rect.x, "y":self.rect.y, "width":self.rect.width, "height":self.rect.height, "things":[thing.toJson() for thing in self.things ]}