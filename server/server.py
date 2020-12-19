import socket
from _thread import start_new_thread
import _pickle as pickle
import time
import random
import math
import json
from game import Game

S = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
S.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

PORT = 5555

HOST_NAME = '217.182.216.146' #socket.gethostname()
SERVER_IP = '217.182.216.146' #socket.gethostbyname(HOST_NAME) 

start = False
connections = []
_id = 0
players = {}

try:
    S.bind((SERVER_IP, PORT))
except socket.error as e:
    print(str(e))
    print("[SERVER] Server could not start")
    quit()

S.listen() 


print(f"[SERVER] Server started with local ip {SERVER_IP} and listens on port {PORT}")


#The Game
game = Game()


def main_thread():
	global connections
	game_time = time.time()
	while True:
		try:
			game.update()
			update_time = time.time() - game_time
			game_time = time.time()

			# send data back to clients
			for conn in connections:
				data = json.dumps({"worldstate": game.return_world_for_player(conn[1] + 1000), "gametime": update_time}) + ";"
				conn[0].sendall(data.encode("utf-8"))
		
		except Exception as e:
			print("Exception: ", e)

		time.sleep(0.1)


# MAINLOOP

print("[SERVER] Waiting for connections")


def threaded_client(conn, _id):
	global connections

	current_id = _id + 1000

	# recieve a name from the client
	data = conn[0].recv(32)
	name = data.decode("utf-8")
	print("[LOG]", name, "connected to the server.")
	player = game.add_player(current_id)
	print("[LOG] New Player: ",  player)

	data = "#" +  json.dumps({"player": player.toJson(), "worldstate":game.return_world_for_player(current_id)}) + ";" 
	conn[0].sendall(data.encode("utf-8"))

	while True:
		try:
			# Recieve data from client
			data = conn[0].recv(128)

			if not data:
				break


			player_data = json.loads(data.decode("utf-8"))
			mode = player_data["mode"]
			dest_x = player_data["x"]
			dest_y = player_data["y"]
			if (mode == "CharacterMode.Walk"):
				game.set_destination(current_id, dest_x, dest_y)
			elif (mode == "CharacterMode.Attack"):
				game.add_bullet(current_id, dest_x, dest_y)			
			elif (mode == "CharacterMode.WorldChange"):
				player = game.change_world_for_player(current_id)
				send_data = "#" +  json.dumps({"player": player.toJson(), "worldstate":game.return_world_for_player(current_id)}) + ";" 
				conn[0].sendall(send_data.encode("utf-8"))	
		except Exception as e:
			print(e)
			print("ErrorData: ", player_data)
			break  # if an exception has been reached disconnect client

		time.sleep(0.03)

	# When user disconnects	
	print("[DISCONNECT] Name:", name, ", Client Id:", current_id, "disconnected")

	connections.remove(conn) 
	conn[0].close()  # close connection


# MAINLOOP

print("[SERVER] Started main thread: Waiting for connections")

# Keep looping to accept new connections
while True:
	
	host, addr = S.accept()
	print("[CONNECTION] Connected to:", addr)

	# start game when a client on the server computer connects
	if  not(start):
		start_new_thread(main_thread, ())

		start = True
		start_time = time.time()
		print("[STARTED] Started")

	# increment connections start new thread then increment ids
	connections.append((host, _id))
	start_new_thread(threaded_client,((host,_id), _id))
	_id += 1

# when program ends
print("[SERVER] Server offline")
