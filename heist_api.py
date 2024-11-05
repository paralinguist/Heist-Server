from websocket import create_connection
import threading
import json

active = True
server_message = ''

#variables from server:
#encounter_state (WAITING, IN_PROGRESS, ENDED_FAIL, ENDED_WIN, UDEAD)

playername = 'Clarence'
role = 'lockpick'
connection_id = 0

server_fails = 0

#Listener thread receives responses from the server
#It writes to global variables for access via other functions
def listener(_server):
    server = _server
    global server_message
    global server_fails
    global active
    while active:
        try:
            server_message = server.recv().decode("utf-8")
            if server_message.startswith('state|'):
                state = json.loads(server_message[6:])
                global playername
                playername = state['name']
                global connection_id
                connection_id = state['id']
            else:
                print(server_message, end='\n> ')
        except:
            disconnect()

def send(message):
    global server
    server.send(f"{role}|{message}")

def move(direction):
    global server
    server.send(f"move|{role}|{direction}")

def disconnect():
    print("Disconnecting...")
    global server
    global active
    active = False
    server.close()

#Join request sent using: "join|<role>"
def connect(_role, _ip, _port):
    global server
    role = _role
    connected = False
    print("About to try")
    try:
        print("Connecting to server")
        server = create_connection(f"ws://{_ip}:{_port}")
        print("sending to server")
        server.send(f"join|{role}")
        #game_ip_address = server.recv().decode("utf-8")
        listener_thread = threading.Thread(target = listener, args=(server,))
        listener_thread.start()
        connected = True
    except:    
        print("Error connecting to the server.")
    return connected