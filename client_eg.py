import heist_api

ip = "127.0.0.1"
port = 9876
role = "lockpick"

heist_api.connect(role, ip, port)

message = ""

while message != "quit":
    message = input('> ')
    if message == "print":
      print(f"My ID: {heist_api.connection_id}")
    elif message == "up":
        heist_api.move("up")
    elif message == "down":
        heist_api.move("down")
    elif message == "left":
        heist_api.move("left")
    elif message == "right":
        heist_api.move("right")
    else:
      heist_api.send(message)

heist_api.disconnect()
