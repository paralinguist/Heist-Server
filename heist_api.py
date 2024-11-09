from websocket import create_connection
import threading
import json

api_version = "1.01"
client_type = "python"

active = True
server_message = ''
server = None

#variables from server:
#encounter_state (WAITING, IN_PROGRESS, ENDED_FAIL, ENDED_WIN, UDEAD)

playername = 'Clarence'
role = 'lockpick'
connection_id = 0

server_fails = 0

#Listener thread receives responses from the server
#It writes to global variables for access via other functions
def listener(_server):
    global server_message
    global server_fails
    global active
    while active:
        try:
            server_message = _server.recv().decode("utf-8")
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

#Instruction must already have at least an action
def send_instruction(instruction):
    instruction["role"] = role
    instruction["version"] = api_version
    server.send(json.dumps(instruction))

def move(direction):
    instruction = {"action":"move", "direction":direction}
    send_instruction(instruction)

def disconnect():
    print("Disconnecting...")
    global server
    global active
    active = False
    server.close()

def connect(_role, _ip, _port):
    global server
    role = _role
    connected = False
    try:
        server = create_connection(f"ws://{_ip}:{_port}")
        instruction = {"action":"join"}
        send_instruction(instruction)
        listener_thread = threading.Thread(target = listener, args=(server,))
        listener_thread.start()
        connected = True
    except:    
        print("Error connecting to the server.")
    return connected