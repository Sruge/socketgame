
import pygame
import json

class Bullet:
    def __init__(self, id, x, y, dest_x, dest_y, bullettype):
        self.x = x
        self.y = y
        self.destination_x = dest_x
        self.destination_y = dest_y
        self.vel_x = 500 * dest_x / (abs(dest_x) + abs(dest_y))
        self.vel_y = 250 * dest_y / (abs(dest_x) + abs(dest_y))
        self.id = id
        self.bullettype = bullettype
        self.rect = pygame.Rect((x,y ),(200,200))
        self.lifestate = 1
        self.lifetime = 40
        self.timer = 0

    def update(self, time):
        print("Bullet update in progress: ", self.timer, self.lifestate, self.rect)
        self.timer += 1
        if (self.timer > self.lifetime):
            self.lifestate = 0
        self.rect.move_ip(self.vel_x, self.vel_y)
        
    def toJson(self):
        return {"id":self.id,"x":self.rect.x, "y":self.rect.y, "type":self.bullettype}