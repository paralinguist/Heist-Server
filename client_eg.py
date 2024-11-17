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
    elif message.split(" ")[0] in ["hack", "pick", "change", "read"]:
        all_mess = message.split(" ")
        instruction = {}
        instruction["action"] = all_mess[0]
        instruction["item"] = int(all_mess[1])
        heist_api.send_instruction(instruction)
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
        if response["type"] == "safe":
            print(response["data"])

heist_api.disconnect()
