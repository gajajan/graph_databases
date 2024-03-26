import os
import time

IMPORT_DIR = r"C:\Users\gajaj\Desktop\School\Bachelor\graph_databases\import\OrientDB\Youtube"
OETL_DIR = r'C:\Users\gajaj\orientdb-tp3-3.2.23\bin'
OETL_FILE = "oetl.bat"

os.chdir(OETL_DIR)

def make_json_file_path (file_name):
    return IMPORT_DIR + "\\" + file_name + ".json"

vertex_file_names = ["properties"]

edge_file_names = []


print("\n---VERTICES IMPORT---\n")
for vertex_file_name in vertex_file_names:
    json_file_path = make_json_file_path(vertex_file_name)
    batch_command = OETL_FILE + " " + json_file_path
    print(batch_command)
    start = time.time()
    os.system(batch_command)
    end = time.time()
    print("\nTakes: " + str(end - start)+ "s\n\n")

print("\n---EDGE IMPORT---\n")
for edge_file_name in edge_file_names:
    json_file_path = make_json_file_path(edge_file_name)
    batch_command = OETL_FILE + " " + json_file_path
    print(batch_command)
    start = time.time()
    os.system(batch_command)
    end = time.time()
    print("\nTakes: " + str(end - start)+ "s\n\n")