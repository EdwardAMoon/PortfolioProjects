from random import choice

class RandomWalk:
    """A class to generate random walks"""

    def __init__(self, num_points = 5000):
        """Initialise attributes of a walk"""
        self.num_points = num_points

        #All walks start at (0, 0)
        self.x_values = [0]
        self.y_values = [0]

    def fill_walk(self):
        """Calculate all the points in the walk"""
        #Keep taking seteps until the walk reaches the desired length
        while len(self.x_values) < self.num_points:

            #Decide which direction to go, and how far to go
            x_step = self.get_step()
            y_step = self.get_step()

            #Reject moves that go nowhere
            if x_step == 0 and y_step == 0:
                continue

            #Calculate the new position
            x = self.x_values[-1] + x_step
            y = self.y_values[-1] + y_step

            self.x_values.append(x)
            self.y_values.append(y)

    def get_step(self):
        """Calculate a single step in the walk"""
        direction = choice([1, -1])
        distance = choice([0, 1, 2, 3, 4,])
        step = direction * distance

        return step

########################################################

#random walk visual

import matplotlib.pyplot as plt

from random_walk import RandomWalk

#Keep making new walks, as long as the programme is active
while True:
    #Make a random walk
    rw = RandomWalk(5_000)
    rw.fill_walk()

    #Plot the points in the walk
    plt.style.use('classic')
    fig, ax = plt.subplots(figsize =(10, 6), dpi = 128)
    point_numbers = range(rw.num_points)
    ax.plot(rw.x_values, rw.y_values, linewidth = 1)
    ax.set_aspect('equal')

    #Emphasise the first and last points
    ax.scatter(0, 0, c='green', edgecolors = 'none', s=100)
    ax.scatter(rw.x_values[-1], rw.y_values[-1], c='red', edgecolors = 'none', s=100)

    #Remove the axes
    ax.get_xaxis().set_visible(False)
    ax.get_yaxis().set_visible(False)

    plt.show()

    keep_running = input("Make another walk? (y/n): ")
    if keep_running == 'n':
        break
