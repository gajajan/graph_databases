import pandas
import matplotlib.pyplot as plt

COLORS = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b']
OFFSET = 6
ROWS = 5
PLOT_NUMBER = 2
SHEET_NAME = 'properties'
EXCEL_NAME = "Measurement.xlsx"
FIG_PATH="kidiplom/graphics/properties-test.png"

def make_plot(df, i):
    plt.subplot(3, 2, i+1)
    for j in range(1,ROWS):
        x = df.loc[0 + i*OFFSET, 1:10]
        y = df.loc[j + i*OFFSET, 1:10]
        plt.xlabel("Pokus")
        #ylabel will be only on the left side
        if i % 2 == 0:
            plt.ylabel("Čas[s]", fontsize=12)
        plt.plot(x,y)
    plt.title(df.loc[0 + i*OFFSET, 0])

def make_bars(test_data, i):
    plt.subplot(3, 2, i+1)
    
    x,y = [], []
    for j in range(1,ROWS):
        #filter Nan values
        if not pandas.isna(test_data.loc[j + i*OFFSET, 11]):
            x.append(test_data.loc[j + i*OFFSET, 0])
            y.append(test_data.loc[j + i*OFFSET, 11])
    #ylabel will be only on the left side
    if i % 2 == 0:
        plt.ylabel("Čas[s]", fontsize=12)
    
    plt.xticks(rotation = 45, fontsize=12)
    plt.yticks(fontsize=12)
    plt.grid(axis='y')
    plt.bar(x,y, color=COLORS)
    plt.title(test_data.loc[0 + i*OFFSET, 0], fontsize=20)


df = pandas.read_excel(EXCEL_NAME, header=None, sheet_name=SHEET_NAME, usecols = "A:L")
plt.figure(figsize=(10, 14))
for i in range(0,PLOT_NUMBER):
    make_bars(df.iloc[i*OFFSET:i*OFFSET+ROWS], i)


plt.subplots_adjust(left=0.08, bottom=0.04, right=0.96, top=0.96, wspace=0.2, hspace=0.5)
plt.savefig(FIG_PATH, bbox_inches="tight")
