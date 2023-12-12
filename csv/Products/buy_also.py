import csv
import random

ids = set()
with open(r"C:\Users\gajaj\Desktop\School\Bachelor\graph_databases\csv\Products\myntra_products_catalog.csv", mode="r") as readed_file:
    reader = csv.reader(readed_file, delimiter=",")
    next(reader, None)
    for line in reader:
        ids.add(line[0])

values = [100, 1, 0.699, 0.522, 0.398, 0.301, 0.222, 0.155, 0.097, 0.046, 0]
weights = [0.02, 0.03, 0.095, 0.19, 0.23, 0.19, 0.13, 0.06, 0.03, 0.02, 0.005]

with open(r"C:\Users\gajaj\Desktop\School\Bachelor\graph_databases\csv\Products\buys_also.csv", mode="w", newline='') as write_file:
     writer = csv.writer(write_file, delimiter=",")
     for source_id in ids:
         k = random.randint(5,125)
         indicies = random.sample(ids, k)
         for dest_id in indicies:
            frequency = random.choices(values, weights)
            writer.writerow([source_id, dest_id, frequency[0]])