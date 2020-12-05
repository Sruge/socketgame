
import pygame
import json

class Player:
    def __init__(self, id, x, y, pltype):
        self.x = x
        self.y = y
        self.destination_x = x
        self.destination_y = y
        self.vel_x = 0
        self.vel_y = 0
        self.id = id
        #directions: 0 is left, 1 up, 2 right, 3 down (walking) and the next 4 are the same (standing)
        self.direction = 7
        self.pltype = pltype
        self.rect = pygame.Rect((x,y),(32,48))
        
    def move(self, time):
        if (abs(self.vel_y * 0.7) > abs(self.vel_x)):
            if (self.vel_y > 0):
                self.direction = 3
            else:
                self.direction = 1
        elif (self.vel_x is not 0):
            if (self.vel_x > 0):
                self.direction = 2
            else:
                self.direction = 0
        elif (self.direction < 4):
            self.direction = self.direction + 4


        self.x = self.x + (self.vel_x * time)
        self.y = self.y + (self.vel_y * time)
        if ((self.vel_x > 0 and self.x > self.destination_x) or (self.vel_x < 0 and self.x < self.destination_x)):
            self.vel_x = 0
        if ((self.vel_y > 0 and self.y > self.destination_y) or (self.vel_y < 0 and self.y < self.destination_y)):
            self.vel_y = 0
            
            
    def set_destination(self, x ,y):
        self.destination_x = self.x + x
        self.destination_y = self.y + y
        dx = (self.destination_x - self.x)
        dy = (self.destination_y - self.y)
        self.vel_x = 5 * dx / (abs(dx) + abs(dy))
        self.vel_y = 5 * dy / (abs(dx) + abs(dy))
        print("New Player Destination: ", self.destination_x, ", ", self.destination_y)
        
    def toJson(self):
        return {"id":self.id,"x":self.x, "y":self.y, "type":self.pltype, "dir": self.direction}
