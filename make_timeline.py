from __future__ import division
from datetime import datetime


class Month(object):

    def __init__(self, date, debt, retirement, down):
        self.date = date
        self.debt = debt
        self.retirement = retirement
        self.down = down

    def __str__(self):
        return "{DATE},{SD},{R},{DOWN}".format(
            DATE=self.date.isoformat(),
            SD=self.debt,
            R=self.retirement,
            DOWN=self.down
        )

loans = 121000
monthlydebt = 2000
retirement = 833
down = 2300
months = [Month(datetime(2018, 5, 1, 1, 1), loans, 24000, 0)]

taken = 0
while loans > 0:
    taken += 1
    previous = months[-1]
    month = (previous.date.month) % 12 + 1
    year = previous.date.year + previous.date.month // 12
    current = Month(
        datetime(year, month, 1, 1, 1),
        previous.debt - monthlydebt,
        previous.retirement + retirement,
        0)
    months.append(current)
    loans -= monthlydebt

months[-1].down = -months[-1].debt
months[-1].debt = 0

for _ in range(5*12):
    previous = months[-1]
    month = (previous.date.month) % 12 + 1
    year = previous.date.year + previous.date.month // 12
    current = Month(
        datetime(year, month, 1, 1, 1),
        0,
        previous.retirement + retirement,
        previous.down + down)
    months.append(current)
    loans -= monthlydebt

csv = 'date, student_loans, retirement, down_payment\n{DATA}'.format(
    DATA='\n'.join([str(month) for month in months])
)

print(csv)
