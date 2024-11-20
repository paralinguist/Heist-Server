import heist_api
import time

ip = "127.0.0.1"
port = 9876
role = "charmer"

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
    elif message.split(" ")[0] in ["hack", "pick", "use", "distract"]:
        message_list = message.split(" ")
        target_id = int(message_list[1])
        match message_list[0]:
            case "hack":
                #Can send "begin" (default), "success", "failed", "cancel"
                if len(message_list) == 3:
                    heist_api.hack(target_id, message_list[2])
                else:
                    heist_api.hack(target_id)
            case "pick":
                #Can send "begin" (default), "success", "failed", "cancel"
                if len(message_list) == 3:
                    heist_api.pick(target_id, message_list[2])
                else:
                    heist_api.pick(target_id)
            case "use":
                heist_api.use(target_id)
            case "distract":
                heist_api.distract(target_id)
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
        elif response["type"] == "safe":
            print(response["data"])
        elif response["type"] == "begin_action":
            print(response["data"])

heist_api.disconnect()
