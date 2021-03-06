from thing import Thing
from door import Door
import pygame

def get_thing_data(object_type):
    if (object_type == "tree"):
        return ["tree", 3000, 4000, pygame.Rect(1000, 3000, 1000, 1000)]
    elif (object_type == "house"):
        return ["house", 4500, 6000, pygame.Rect(0, 3000 , 4500, 3000)]
    elif (object_type == "bank"):
        return ["bank", 5000, 7000, pygame.Rect(0, 3500 , 5000, 3500)]
    elif (object_type == "fence"):
        return ["fence", 8000, 1500, pygame.Rect(0, 1000 , 8000, 500)]

def get_door_data(object_type):
    if (object_type == "door1"):
        return ["door1", 1300, 1500, "insideHouse"]
    elif (object_type == "door2"):
        return ["door2", 1300, 1500, "beach"]
    elif (object_type == "door3"):
        return ["door3", 1300, 1500, "japaneseVillage"]

def get_world_data(world_type):
    if (world_type == "japaneseVillage"):
        return ["japaneseVillage", 60000, 30000]
    elif (world_type == "beach"):
        return ["beach", 60000, 30000]
    elif (world_type == "insideHouse"):
        return ["insideHouse", 20000, 10000]

def get_doors_for_world(world_type):
    if (world_type == "japaneseVillage"):
        door = Door(1, 1000, 1000, "door1")
        return [door]
    elif (world_type == "beach"):
        door = Door(1, 10000, 10000, "door1")
        return [door] 
    elif (world_type == "insideHouse"):
        door = Door(1, 5000, 500, "door1")
        return [door] 

def get_things_for_world(world_type):
    if (world_type == "japaneseVillage"):
        things = [Thing(1, 10000, 10000, "tree")
            ,Thing(2, 20000, 10000, "tree"),
            Thing(3, 25000, 11000, "tree"),
            Thing(4, 28000, 10500, "tree"),
            Thing(5, 50000, 20000, "tree"),
            Thing(6, 1000, 5000, "house"),
            Thing(7, 6000, 5000, "house"),
            Thing(8, 1000, 15000, "house"),
            Thing(9, 30000, 10000, "house"),
            Thing(10, 30000, 10000, "house"),
            Thing(11, 30000, 10000, "house"),
            Thing(13, 45000, 20000, "bank"),
            Thing(14, 3000, 25000, "fence"),
            Thing(15, 11000, 25000, "fence"),
            Thing(16, 19000, 25000, "fence"),
            Thing(17, 27000, 25000, "fence"),]
        return things
    elif (world_type == "beach"):
        things = [Thing(1, 10000, 10000, "tree")
            ,Thing(2, 20000, 10000, "tree"),
            Thing(3, 25000, 11000, "tree"),
            Thing(4, 28000, 10500, "tree"),
            Thing(5, 50000, 20000, "tree"),
            Thing(6, 1000, 5000, "house"),
            Thing(7, 6000, 5000, "house"),
            Thing(8, 1000, 15000, "house"),
            Thing(9, 30000, 10000, "house"),
            Thing(10, 30000, 10000, "house"),
            Thing(11, 30000, 10000, "house"),
            Thing(13, 45000, 20000, "bank"),
            Thing(14, 3000, 25000, "fence"),
            Thing(15, 11000, 25000, "fence"),
            Thing(16, 19000, 25000, "fence"),
            Thing(17, 27000, 25000, "fence"),]
        return things
    elif (world_type == "insideHouse"):
        things = [Thing(1, 10000, 10000, "tree")
            ,Thing(2, 20000, 10000, "tree"),
            Thing(3, 25000, 11000, "tree"),
            Thing(4, 28000, 10500, "tree"),
            Thing(5, 50000, 20000, "tree"),
            Thing(6, 1000, 5000, "house"),
            Thing(7, 6000, 5000, "house"),
            Thing(8, 1000, 15000, "house"),
            Thing(9, 30000, 10000, "house"),
            Thing(10, 30000, 10000, "house"),
            Thing(11, 30000, 10000, "house"),
            Thing(13, 45000, 20000, "bank"),
            Thing(14, 3000, 25000, "fence"),
            Thing(15, 11000, 25000, "fence"),
            Thing(16, 19000, 25000, "fence"),
            Thing(17, 27000, 25000, "fence"),]
        return things