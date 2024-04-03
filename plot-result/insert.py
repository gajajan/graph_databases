import pandas
import matplotlib.pyplot as plt

insert = pandas.read_excel("Measurement.xlsx", sheet_name='insert-delete', usecols = "A:E")
df = insert.iloc[0:4]

x = range(4)
print()
bar_height = 0.2

plt.figure(figsize=(10, 4))
plt.barh(x, df['Neo4j'], height=bar_height, label='Neo4j')
plt.barh([i + bar_height for i in x], df['OrientDB'], height=bar_height, label='OrientDB')
plt.barh([i + 2 * bar_height for i in x], df['ArangoDB'], height=bar_height, label='ArangoDB')

plt.xlabel('Čas[s]', fontsize=12)
plt.yticks([i + 1.5 * bar_height for i in x], df['Unnamed: 0'], fontsize=12)
plt.xticks(range(0,801,100),fontsize=12)
plt.minorticks_on()
plt.legend(fontsize=12)
plt.grid(axis='x')
plt.savefig("kidiplom/graphics/insertDelete.png", bbox_inches="tight")