import csv

with open("station_to_station.csv", mode="r", newline='') as read_file:
    with open ("station_to_station2.csv", mode="w", newline='') as write_file:
        reader = csv.reader(read_file, delimiter=";")
        writer = csv.writer(write_file, delimiter=";")
        for line in reader:
            writer.writerow(line[1:])