import pandas as pd
import plotly.plotly as py
from plotly.graph_objs import *
import numpy as np

data = pd.read_csv("/home/nikhil/Desktop/destination.csv")
data.columns = ["destination", "time"]
list_destination = list(data.destination)
list_time = list(data.time)
print list_destination
print list_time
array_destination = np.asarray(list_destination)
array_time = np.asarray(list_time)

trace1 = Bar(x=array_destination,y=array_time)

data = Data([trace1])
py.plot(data,filename='Time_to_reach_destination')
