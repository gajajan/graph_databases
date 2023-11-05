import csv

dest = dict()
offers = []
activities = []
with open(r"C:\Users\gajaj\Desktop\ŠKOLA\Bakalářka\graph_databases\csv\TravelEnthusiastNetwork\destinations.csv", mode="r") as file:
    reader = csv.reader(file, delimiter=",")
    line = 0
    for line in reader:
        if line == 0:
             line = 1
             continue
        dest[line[0]] = line[1]

print(activities)
print(offers)
print(dest)