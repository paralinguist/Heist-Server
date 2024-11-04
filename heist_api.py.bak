from websocket import create_connection
import threading
import asyncio
import json

active = True
server_message = ''

#variables from server:
#encounter_state (WAITING, IN_PROGRESS, ENDED_FAIL, ENDED_WIN, UDEAD)
#boss_balance (integer - balance remaining)
#num_musos (integer - how many musos are connected)
#muso_list (list - from json - of muso dicts)

playername = 'Muso'
instrument = 'Voice'
max_irritation = 200
current_irritation = 0
interference = 0
soothe = 0
resonance = 0
harmonics = 0
connection_id = 0

server_fails = 0

#Listener thread receives responses from the server
#It writes to global variables for access via other functions
def listener(server):
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
        global instrument
        instrument = state['instrument']
        global max_irritation
        max_irritation = state['max_irritation']
        global current_irritation
        current_irritation = state['irritation']
        global interference
        interference = state['interference']
        global soothe
        soothe = state['soothe']
        global resonance
        resonance = state['resonance']
        global harmonics
        harmonics = state['harmonics']
      else:
        print(server_message, end='\n> ')
    except:
      print('no valid message from server')
      server_fails += 1
      if server_fails >= 3:
        active = False

def send(message):
  global server
  server.send(message)

def disconnect():
  global server
  global active
  active = False
  server.close()

#Usernames are sent using ||: as a delimiter
#For robustness in future, should be base64 encoded or similar
def connect(name, ip, port=8765):
  global server
  server = create_connection(f'ws://{ip}:{port}')
  server.send(f'||:{name}')
  conn_id = server.recv()
  print(conn_id)
  message = ''
  listener_thread = threading.Thread(target = listener, args=(server,))
  listener_thread.start()
