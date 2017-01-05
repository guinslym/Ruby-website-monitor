import datetime
import calmap
import pandas as pd
import matplotlib.pyplot as plt
from collections import deque


def getDowntimeEvents(events, year):
    start = datetime.date(year, 1, 1)
    days = pd.date_range(start, periods=365, freq='D')
    eventList = [0.0] * 365
    for event in events:
        if event.split()[1] == "down":
            timestamp = int(event.split()[0])
            if isInYear(timestamp, year):
                daynum = timestampToDayNumber(timestamp)
                eventList[daynum-1] += 1.0
    return pd.Series(eventList, index=days)


def isInYear(timestamp, year):
    return timestampToDate(timestamp).year == year


def timestampToDate(timestamp):
    return datetime.date.fromtimestamp(timestamp)


def timestampToDayNumber(timestamp):
    return datetime.date.fromtimestamp(timestamp).timetuple().tm_yday

year = 2017  # change this to the year you want to analyze

with open('output.txt') as f:
    events = f.read().splitlines()

downtime = getDowntimeEvents(events, year)
calmap.yearplot(downtime, year=year)
plt.show()
