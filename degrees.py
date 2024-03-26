import pandas
import matplotlib.pyplot as plt

deg = pandas.read_excel("../degrees.xlsx", sheet_name='export', usecols = "A:B")


plt.figure(figsize=(10, 4))
plt.bar(deg["degree"], deg["userCount"], width=1)

# Nastavení logaritmického měřítka na ose y
plt.yscale('log', base=10)

plt.xlabel('Stupeň', fontsize=12)
plt.ylabel('Počet uživatelů', fontsize=12)
plt.xlim(1, 2000)
plt.grid(True)
plt.xticks(fontsize=12)
plt.yticks(fontsize=12)
plt.savefig("kidiplom/graphics/youtube-log.png", bbox_inches="tight")