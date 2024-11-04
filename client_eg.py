import heist_api

ip = '127.0.0.1'
port = 9876
role = 'lockpick'

print("Calling API")
heist_api.connect(role, ip, port)

message = ''

while message != 'quit':
    message = input('> ')
    if message == 'print':
      print(f'My ID: {heist_api.connection_id}')
    else:
      heist_api.send(message)

heist_api.disconnect()
