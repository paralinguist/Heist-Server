import heist_api
import time

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
        print("Not an option.")
    time.sleep(0.1)
    for response_number in range(len(heist_api.message_stack)):
        response = heist_api.message_stack.pop()
        #You can iterate over the environment list and look for objects of a type relevant to your character
        if response["type"] == "environment":
            for item in response["response"]:
                if item['type'] != 'none':
                    print(item)

heist_api.disconnect()
