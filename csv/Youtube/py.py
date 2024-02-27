# Načtení TSV souboru
file_path = r'C:\Users\gajaj\Desktop\School\Bachelor\graph_databases\csv\Youtube\com-youtube.ungraph.tsv'
with open(file_path, 'r') as file:
    lines = file.readlines()

# Extrahování a sloučení unikátních ID z obou sloupců
unique_ids = set()
for line in lines[1:]:  # Preskočení záhlaví
    from_id, to_id = line.strip().split('\t')
    unique_ids.add(from_id)
    unique_ids.add(to_id)

# Zápis unikátních ID do jiného souboru
output_file_path = 'users.csv'
with open(output_file_path, 'w') as output_file:
    for node_id in unique_ids:
        output_file.write(node_id + '\n')

print("Unikátní ID byly zapsány do souboru:", output_file_path)