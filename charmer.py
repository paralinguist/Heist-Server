import asyncio
from os import system, name
import heist_api
from prompt_toolkit.input import create_input
from prompt_toolkit.keys import Keys
from prompt_toolkit.styles import Style
from prompt_toolkit import print_formatted_text, HTML
from time import sleep

server_ip = "127.0.0.1"
port = 9876
role = "charmer"
heist_api.connect(role, server_ip, port)

MOVE = 0
DISTRACT = 1

mode = MOVE
correct = "q"

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
    print("""To keep the guard distracted, show them you belong here by dropping
information only an employee would know. Press Q to go back to move mode.""")
    print()
    print("Oh hey <name>, how's <child's name>'s band practice going?")
    print()
    print("A) Timmy")
    print("B) Jane")
    print("C) Gerald")
    print("D) Amanda")
    print()
    return "a"

async def main() -> None:
    done = asyncio.Event()
    input = create_input()

    def keys_ready():
        global mode
        global correct
        for key_press in input.read_keys():
            if key_press.key == Keys.ControlC:
                heist_api.disconnect()
                done.set()
            else:
                if mode == DISTRACT:
                    if key_press.key == correct:
                        print("Correct! The guard is distracted.")
                        correct = distract_game()
                    elif key_press.key == "q":
                        mode = MOVE
                        print("Noping out...")
                    else:
                        mode = MOVE
                        print("Incorrect. The guard is suspicious.")
                    print()
                    print("3")
                    sleep(1)
                    print("2")
                    sleep(1)
                    print("1")
                    sleep(1)
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
                        mode = DISTRACT
                        print_formatted_text(HTML("<pink>CHARMING</pink>"))
                        correct = distract_game()


    with input.raw_mode():
        with input.attach(keys_ready):
            await done.wait()


if __name__ == "__main__":
    asyncio.run(main())
