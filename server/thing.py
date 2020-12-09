
import pygame
import json
import utils

class Thing:
    def __init__(self, id, x, y, thing_type):
        self.id = id
        self.object_data = utils.get_thing_data(thing_type)
        self.object_name = self.object_data[0]
        self.rect = pygame.Rect((x,y),(self.object_data[1],self.object_data[2]))
        self.bottomRect = pygame.Rect(self.object_data[3].x + self.rect.x, self.object_data[3].y + self.rect.y, self.object_data[3].width, self.object_data[3].height)

                
    def toJson(self):
        return {"id":self.id,"type": self.object_name, "x":self.rect.x, "y":self.rect.y, "width":self.rect.width, "height": self.rect.height}