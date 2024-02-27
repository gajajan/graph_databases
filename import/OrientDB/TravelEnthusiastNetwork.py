import os

JSON_DIR = r"C:\Users\gajaj\Desktop\School\Bachelor\graph_databases\import\OrientDB\TravelEnthusiastNetwork"
OETL_DIR = r'C:\Users\gajaj\orientdb-tp3-3.2.23\bin'
OETL_FILE = "oetl.bat"

os.chdir(OETL_DIR)

def make_json_file_path (file_name):
    return JSON_DIR + "\\" + file_name + ".json"

vertex_file_names = ["activities", "countries", "destinations", "journeys", "ratings", "users"]

edge_file_names = ["follows", "is_within", "led_to", "likes", "lives_in", "offers", "participated", "wrote_about"]


print("\n---VERTICES IMPORT---\n")
for vertex_file_name in vertex_file_names:
    json_file_path = make_json_file_path(vertex_file_name)
    batch_command = OETL_FILE + " " + json_file_path
    print(batch_command)
    os.system(batch_command)

print("\n---EDGE IMPORT---\n")
for edge_file_name in edge_file_names:
    json_file_path = make_json_file_path(edge_file_name)
    batch_command = OETL_FILE + " " + json_file_path
    print(batch_command)
    os.system(batch_command)