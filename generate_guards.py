import random
import json
family = ["Kai","Amaya","Alix","Nala","Charlie","Evelyn","Logan","Morgan","Leilani"]

dislikes = ["TPS reports","morning meetings","micromanagement","office politics","training sessions","webinars","computer updates"]

passions = ["increased efficiencies","union representations","holiday time","health and safety","free coffee","pool table in the break room","longer lunch breaks"]

guard_names = ["Akira", "Gabriel", "Riley", "Kaiya", "Jaiden", "Ella", "Daniel", "Christian"]

guards = []

for i in range(3):
    for guard_name in guard_names:
        guard = {}
        guard["id"] = str(random.randint(10000,99999))
        guard["name"] = guard_name
        guard["family"] = random.choice(family)
        guard["dislike"] = random.choice(dislikes)
        guard["passion"] = random.choice(passions)
        guards.append(guard)

with open("hrfile.json", "w", encoding='utf-8') as hrfile:
    json.dump(guards, hrfile, ensure_ascii=False, indent=4)

