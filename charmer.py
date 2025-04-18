import asyncio
import json
from os import system, name
import heist_api
from prompt_toolkit.input import create_input
from prompt_toolkit.keys import Keys
from prompt_toolkit.styles import Style
from prompt_toolkit import print_formatted_text, HTML
from time import sleep
from random import randint, choice, shuffle

server_ip = "127.0.0.1"
port = 9876
role = "charmer"
heist_api.connect(role, server_ip, port)

MOVE = 0
DISTRACT = 1

mode = MOVE
correct = "q"
target_id = 0
begin_distract = False

guard_data = {}

def read_dialogue(topic):
    dialogue = []
    with open(f"{topic}_dialogue.txt", "r") as file:
        dialogue = ([line.rstrip() for line in file])
    return dialogue

family = ["Kai","Amaya","Alix","Nala","Charlie","Evelyn","Logan","Morgan","Leilani"]
family_dialogue = read_dialogue("family")

dislikes = ["TPS reports","morning meetings","micromanagement","office politics","training sessions","webinars","computer updates"]
dislike_dialogue = read_dialogue("dislike")

passions = ["increased efficiencies","union representations","holiday time","health and safety","free coffee","pool table in the break room","longer lunch breaks"]
passion_dialogue = read_dialogue("passion")

charmer_help = """<pink>You are the charmer.

Use W A S D to move.

When near a guard, press C to charm them for 10 seconds.

If your Earpiece has access to an employee file, you can continue to keep
them distracted.</pink>"""

with open("hrfile.json", "r") as file:
    guards = json.load(file)


def clear():
    if name == 'nt':
        _ = system('cls')
    else:
        _ = system('clear')

clear()
print_formatted_text(HTML(charmer_help))

def distract_game():
    clear()
    topic = randint(1,3)
    answers = []
    correct_answer = ""
    red_herrings = []
    question = ""
    if topic == 1:
        answers = family.copy()
        correct_answer = guard_data["family"]
        question = choice(family_dialogue).replace("*", guard_data["name"])
    elif topic == 2:
        answers = dislikes.copy()
        correct_answer = guard_data["dislike"]
        question = choice(dislike_dialogue).replace("*", guard_data["name"])
    else:
        answers = passions.copy()
        correct_answer = guard_data["passion"]
        question = choice(passion_dialogue).replace("*", guard_data["name"])
    answers.remove(correct_answer)

    for i in range(3):
        red_herring = choice(answers)
        answers.remove(red_herring)
        red_herrings.append(red_herring)

    red_herrings.append(correct_answer)
    shuffle(red_herrings)
    possibilities = red_herrings
    option_letters = ["A", "B", "C", "D"]
    for i in range(len(possibilities)):
        if possibilities[i] == correct_answer:
            correct = option_letters[i].lower()
        possibilities[i] = option_letters[i]+") "+possibilities[i]

    print("""To keep the guard distracted, show them you belong here by dropping
information only an employee would know. Press Q to go back to move mode.""")
    print()
    print(f"This guard is: {guard_data['name'].upper()}")
    print()
    print(question)
    print()
    for possibility in possibilities:
        print(possibility)
    print("Q) Nope out of conversation!")
    print()
    return "a"

async def main() -> None:
    done = asyncio.Event()
    input = create_input()

    def keys_ready():
        global mode
        global correct
        global guard_data
        global target_id
        global begin_distract
        for response_number in range(len(heist_api.message_stack)):
            response = heist_api.message_stack.pop()
            if response["type"] == "environment":
                for item in response["response"]:
                    if item['type'] == 'guard':
                        target_id = item['id']
            elif response["type"] == "begin_action":
                guard_data = response["data"]

        if begin_distract and mode == DISTRACT:
            begin_distract = False
            correct = distract_game()

        for key_press in input.read_keys():
            if key_press.key == Keys.ControlC:
                heist_api.disconnect()
                done.set()
            else:
                if mode == DISTRACT:
                    begin_distract = False
                    if correct == "q":
                        correct = distract_game()
                    else:
                        if key_press.key == correct:
                            print("Correct! The guard is distracted.")
                            heist_api.distract(target_id)
                            sleep(1)
                            correct = distract_game()
                        elif key_press.key == "q":
                            mode = MOVE
                            print("Noping out...")
                        elif key_press.key in ["a", "b", "c", "d"]:
                            mode = MOVE
                            print("Incorrect. The guard is suspicious.")
                            #Need to send a fail and raise sus level
                        if mode == MOVE:
                            print()
                            print("3")
                            sleep(1)
                            print("2")
                            sleep(1)
                            print("1")
                            sleep(1)
                            clear()
                            print_formatted_text(HTML(charmer_help))
                elif mode == MOVE:
                    clear()
                    print_formatted_text(HTML(charmer_help))
                    if key_press.key == "w":
                        heist_api.move("up")
                    elif key_press.key == "s":
                        heist_api.move("down")
                    elif key_press.key == "a":
                        heist_api.move("left")
                    elif key_press.key == "d":
                        heist_api.move("right")
                    elif key_press.key == "c":
                        if target_id != 0:
                            heist_api.distract(target_id)
                            mode = DISTRACT
                            begin_distract = True
                            print_formatted_text(HTML("<pink>CHARMING</pink>"))
                            print("Press space")
                        else:
                            print_formatted_text(HTML("<pink>No guard to charm...</pink>"))


    with input.raw_mode():
        with input.attach(keys_ready):
            await done.wait()


if __name__ == "__main__":
    asyncio.run(main())
