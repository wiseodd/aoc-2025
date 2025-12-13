import numpy as np
import scipy

with open("data/day_10_input_01.txt") as f:
    p2 = 0

    for line in f.read().strip().splitlines():
        target, *buttons, joltages = line.split(" ")

        b1 = list(map(lambda x: x == "#", target[1:-1]))

        n_lights = len(target) - 2  # Exclude brackets
        n_buttons = len(buttons)
        A = np.zeros((n_lights, n_buttons), dtype=int)

        for j, button_str in enumerate(buttons):
            indices = map(int, button_str[1:-1].split(","))  # "(0,3,4)" -> [0,3,4]
            for i in indices:
                A[i, j] = 1

        b2 = list(map(int, joltages[1:-1].split(",")))

        c = [1] * len(buttons)
        p2 += scipy.optimize.milp(c, constraints=[A, b2, b2], integrality=c).fun

    print(p2)
