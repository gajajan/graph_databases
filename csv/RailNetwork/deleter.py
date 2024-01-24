import csv
import ast

# with open(r"csv\RailNetwork\station_to_station.csv", mode="r", newline='') as read_file:
#     with open (r"csv\RailNetwork\station_to_station2.csv", mode="w", newline='') as write_file:
#         reader = csv.reader(read_file, delimiter=";")
#         writer = csv.writer(write_file, delimiter=";")
#         next(reader, None)
#         writer.writerow(["sourceId", "sourceName", "destId", "destName", "length"])
#         for line in reader:
#             writer.writerow(line[1:-1])

names = set()
stations = set()

with open(r"csv\RailNetwork\station_to_station.csv", mode="r", newline='') as read_file:
        reader = csv.reader(read_file, delimiter=";")
        next(reader, None)
        for line in reader:
            if line[1] not in names:
                names.add(line[1])
                d = ast.literal_eval(line[0])
                longitude, latitude = d["coordinates"][-1]
                stations.add((line[1], line[2], latitude, longitude))
            
with open (r"csv\RailNetwork\stations.csv", mode="w", newline='') as write_file:
     writer = csv.writer(write_file, delimiter=",")
     writer.writerow(["stationId", "stationName", "latitude", "longitude"])
     for station in stations:
           writer.writerow(station)