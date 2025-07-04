from math import ceil, sqrt, tau
from functools import cache
import math
from typing import List
import cmath


def get_factor(p: int) -> int | None:
    if not p & 1:
        return 2
    for d in range(3, ceil(sqrt(p)) + 1, 2):
        if not p % d:
            return d


@cache
def get_twiddle(n: int, x: int):
    # e**(x*i*2pi/n)
    x *= tau / n
    x %= tau
    return _get_twiddle(x)


@cache
def _get_twiddle(x: float):
    return cmath.exp(1j * -x)


def compute_fft(A: List[complex | int | float]):
    N = len(A)

    r2 = get_factor(N)

    # base case
    if r2 is None:  # N is prime
        # ideally use Rader's or Bluestein's here
        # but for now this is naive DFT
        return [sum([A[k] * get_twiddle(N, j * k) for k in range(N)]) for j in range(N)]

    r1 = N // r2

    A1 = [0 for _ in range(r2)]

    # compute A1(k0,j0) -- divide
    for k0 in range(r2):
        A1[k0] = compute_fft(A[k0 : (r1 - 1) * r2 + k0 + 1 : r2])

    # merge subproblem results
    X = [0 for _ in range(N)]
    for j1 in range(r2):
        for j0 in range(r1):
            X[j1 * r1 + j0] = sum(
                [
                    A1[k0][j0] * get_twiddle(r2, j1 * k0) * get_twiddle(N, j0 * k0)
                    for k0 in range(r2)
                ]
            )

    return X


data = []

# generate data
# pi = math.pi
# freq = 1 / (2 * pi)
# a = 2 * pi * freq
for x in range(1024):
    data.append(math.sin(1 * x))

# for line in open(r"C:\Users\aiden\Documents\Audacity\sample-data.txt"):
#     data.append(float(line.strip()))

# # compute fft
# fft = compute_fft(data)
# for i in range(len(fft)):
#     fft[i] = abs(fft[i])

# print(fft, end="")


d = [1, 2, 3, 4]
print(d)
print(sum(d))
