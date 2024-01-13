import csv

# with open(r"csv\RailNetwork\station_to_station.csv", mode="r", newline='') as read_file:
#     with open (r"csv\RailNetwork\station_to_station2.csv", mode="w", newline='') as write_file:
#         reader = csv.reader(read_file, delimiter=";")
#         writer = csv.writer(write_file, delimiter=";")
#         next(reader, None)
#         writer.writerow(["sourceId", "sourceName", "destId", "destName", "length"])
#         for line in reader:
#             writer.writerow(line[1:-1])

stations = set()

with open(r"csv\RailNetwork\station_to_station.csv", mode="r", newline='') as read_file:
        reader = csv.reader(read_file, delimiter=";")
        next(reader, None)
        for line in reader:
            stations.add((line[1], line[2]))

            
with open (r"csv\RailNetwork\stations.csv", mode="w", newline='') as write_file:
     writer = csv.writer(write_file, delimiter=",")
     writer.writerow(["stationId", "stationName"])
     for station in stations:
           writer.writerow(station)