import os
import time

CSV_DIR_PATH = r"C:\Users\gajaj\Desktop\School\Bachelor\graph_databases\csv\TravelEnthusiastNetwork"
ARANGOIMPORT_DIR = r'C:\Users\gajaj\ArangoDB3-3.11.7_win64\usr\bin'
DATABASE_NAME = "TravelEnthusiastNetwork"
USERNAME = "root"
PASSWORD = ""
COMMANDS_FILE = r"C:\Users\gajaj\Desktop\School\Bachelor\graph_databases\import\ArangoDB\TravelEnthusiastNetwork\commands.txt"

os.chdir(ARANGOIMPORT_DIR)

with open(COMMANDS_FILE, "r") as file:
    commands = [line.rstrip('\n') for line in file]


for command in commands:
    start = time.time()
    command = command.replace("DATABASE_NAME", DATABASE_NAME)
    command = command.replace("CSV_DIR_PATH", CSV_DIR_PATH)
    command = command.replace("USERNAME", USERNAME)
    command = command.replace("PASSWORD", PASSWORD)
    print(command)
    os.system(command)
    end = time.time()
    print("\nTakes: " + str(end - start)+ "s\n\n")
