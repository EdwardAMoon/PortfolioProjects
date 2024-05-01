# Code to generate a die and a visual of the results, hastag line seperates code for the die and the die visual codes 

from random import randint

class Die:
    """A class representing a single die"""

    def __init__(self, num_sides = 6):
        """Assume a six-sided die"""
        self.num_sides = num_sides

    def roll(self):
        """Return a random value between 1 and number of sides"""
        return randint(1, self.num_sides)

########################################

import plotly.express as px

from die import Die

#Create a 3 X D6
die_1 = Die()
die_2 = Die()


#Make some rolls, and store results in a list
results = []
for roll_num in range(1_000):
    result = die_1.roll() + die_2.roll() 
    results.append(result)

#Analyse the results
frequencies = []
max_result = die_1.num_sides + die_2.num_sides 
poss_results = range(3, max_result+1)
for value in poss_results:
    frequency = results.count(value)
    frequencies.append(frequency)

#Visualise the results
title = "Results of Rolling a D6 amd a D10 50,000 times"
labels = {'x': 'Result', 'y': 'Frequency of Result'}    
fig = px.bar(x=poss_results, y=frequencies, title=title, labels=labels)

#Further customise chart

fig.update_layout(xaxis_dtick=1)

fig.show()
