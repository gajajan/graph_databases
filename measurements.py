import pandas
import matplotlib.pyplot as plt

COLORS = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b']
OFFSET = 8
ROWS = 7

def make_plot(df, i):
    plt.subplot(3, 2, i+1)
    for j in range(1,7):
        x = df.loc[0 + i*8, 1:10]
        y = df.loc[j + i*8, 1:10]
        plt.xlabel("Pokus")
        #ylabel will be only on the left side
        if i % 2 == 0:
            plt.ylabel("Čas[s]", fontsize=12)
        plt.plot(x,y)
    plt.title(df.loc[0 + i*8, 0])

def make_bars(test_data, i):
    plt.subplot(3, 2, i+1)
    
    x,y = [], []
    for j in range(1,7):
        #filter Nan values
        if not pandas.isna(test_data.loc[j + i*8, 11]):
            x.append(test_data.loc[j + i*8, 0])
            y.append(test_data.loc[j + i*8, 11])
    #ylabel will be only on the left side
    if i % 2 == 0:
        plt.ylabel("Čas[s]", fontsize=12)
    
    plt.xticks(rotation = 45, fontsize=12)
    plt.yticks(fontsize=12)
    plt.grid(axis='y')
    plt.bar(x,y, color=COLORS)
    plt.title(test_data.loc[0 + i*8, 0], fontsize=20)


df = pandas.read_excel("Measurement.xlsx", header=None, sheet_name='performance', usecols = "A:L")
plt.figure(figsize=(10, 14))
for i in range(0,6):
    make_bars(df.iloc[i*OFFSET:i*OFFSET+ROWS], i)


plt.subplots_adjust(left=0.08, bottom=0.04, right=0.96, top=0.96, wspace=0.2, hspace=0.5)
plt.savefig("kidiplom/graphics/results.png", bbox_inches="tight")
