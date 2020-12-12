
import pygame
import json
import utils

class Door:
    def __init__(self, id, x, y, door_type):
        self.id = id
        self.object_data = utils.get_door_data(door_type)
        self.object_name = self.object_data[0]
        self.rect = pygame.Rect((x,y),(self.object_data[1],self.object_data[2]))
        self.destination = self.object_data[3]
                
    def toJson(self):
        return {"id":self.id,"type": self.object_name, "x":self.rect.x, "y":self.rect.y, "width":self.rect.width, "height": self.rect.height, "destination":self.destination}