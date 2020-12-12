
import pygame
import json

class Player:
    def __init__(self, id, x, y, health, maxHealth, pltype):
        self.lifestate = 1
        self.x = x
        self.y = y
        self.destination_x = x
        self.destination_y = y
        self.vel_x = 0
        self.vel_y = 0
        self.health = 300
        self.maxHealth = 300
        self.id = id
        #directions animations: 0 is left, 1 up, 2 right, 3 down (walking) and the next 4 are the same (standing)
        self.direction = 7
        self.pltype = pltype
        self.rect = pygame.Rect((x,y),(1000,1200))
        self.worldchange = ""
        
    def update(self, world):
        x = (self.destination_x - self.rect.center[0]) 
        y = (self.destination_y - self.rect.center[1]) 
        self.vel_x = 150 * x / (abs(x) + abs(y))
        self.vel_y = 150 * y / (abs(x) + abs(y))
        self.check_border_boundary_reached(world)
        self.check_object_intersect(world)
        self.check_destination_reached()

        #set the direction animation
        if (abs(self.vel_y * 0.7) > abs(self.vel_x)):
            if (self.vel_y > 0):
                self.direction = 3
            else:
                self.direction = 1
        elif (self.vel_x != 0):
            if (self.vel_x > 0):
                self.direction = 2
            else:
                self.direction = 0
        elif (self.direction < 4):
            self.direction = self.direction + 4

        self.rect.move_ip(self.vel_x, self.vel_y)


        if self.health < 0:
            self.rect.x = 0
            self.rect.y = 0
            self.health = self.maxHealth
            
            
    def set_destination(self, x ,y):
        self.destination_x = self.rect.center[0] + x
        self.destination_y = self.rect.center[1] + y

                

    def check_destination_reached(self):
        if ((self.vel_x > 0 and self.rect.center[0] + self.vel_x > self.destination_x) or
            (self.vel_x < 0 and self.rect.center[0] + self.vel_x < self.destination_x)):
                self.vel_x = 0

        if ((self.vel_y > 0 and self.rect.center[1] + self.vel_y > self.destination_y) or 
            (self.vel_y < 0 and self.rect.center[1] + self.vel_y < self.destination_y)):
                self.vel_y = 0 


    def check_border_boundary_reached(self, world):
        if (self.rect.x + self.vel_x < 0):
            self.rect.x = 0
            self.vel_x = 0
        if (self.rect.x + self.vel_x > world.width):
            self.rect.x = world.width - self.rect.width
            self.vel_x = 0
        if (self.rect.y + self.vel_y < 0):
            self.rect.y = 0
            self.vel_y = 0
        if (self.rect.y + self.vel_y > world.height ):
            self.rect.y = world.height - self.rect.height
            self.vel_y = 0

    def check_object_intersect(self, world):
        player_feet_with_new_x = pygame.Rect((self.rect.x + self.vel_x,self.rect.y + 800),(1000,400))
        player_feet_with_new_y = pygame.Rect((self.rect.x,self.rect.y + 800 + self.vel_y),(1000,400))
        for thing in world.things:
            if (thing.bottomRect.colliderect(player_feet_with_new_x)):
                if (self.vel_x > 0):
                    self.rect.x = thing.bottomRect.x - self.rect.width
                    self.vel_x = 0
                elif (self.vel_x < 0):
                    self.rect.x = thing.bottomRect.x + thing.bottomRect.width
                    self.vel_x = 0
                self.vel_y = self.sign(self.vel_y) * 150

                    
            if (thing.bottomRect.colliderect(player_feet_with_new_y)):
                if (self.vel_y > 0):
                    self.rect.y = thing.bottomRect.y - self.rect.height
                    self.vel_y = 0

                elif (self.vel_y < 0):
                    self.rect.y = thing.bottomRect.y + thing.bottomRect.height + 400 - self.rect.height
                    self.vel_y = 0
                self.vel_x = self.sign(self.vel_x) * 150

    def sign(self, number): 
        """Will return 1 for positive, 
        -1 for negative, and 0 for 0""" 
        try:return number/abs(number) 
        except ZeroDivisionError:return 0 
            
                
    def toJson(self):
        return {"id":self.id,"x":self.rect.x, "y":self.rect.y, "type":self.pltype, "dir": self.direction, "health":self.health, "maxHealth":self.maxHealth}