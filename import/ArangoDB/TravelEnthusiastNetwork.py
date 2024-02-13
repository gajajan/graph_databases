import os

CSV_DIR_PATH = r"C:\Users\gajaj\Desktop\School\Bachelor\graph_databases\csv\TravelEnthusiastNetwork"
ARANGOIMPORT_DIR = r'C:\Users\gajaj\ArangoDB3-3.11.7_win64\usr\bin'
DATABASE_NAME = "TravelEnthusiastNetwork"
USERNAME = "root"
PASSWORD = ""

os.chdir(ARANGOIMPORT_DIR)

with open(r"C:\Users\gajaj\Desktop\School\Bachelor\graph_databases\import\ArangoDB\commands.txt", "r") as file:
    commands = [line.rstrip('\n') for line in file]

for command in commands:
    command = command.replace("DATABASE_NAME", DATABASE_NAME)
    command = command.replace("CSV_DIR_PATH", CSV_DIR_PATH)
    command = command.replace("USERNAME", USERNAME)
    command = command.replace("PASSWORD", PASSWORD)
    print(command)
    os.system(command)

