from __future__ import division
from datetime import datetime


class Month(object):

    def __init__(self, date, debt, retirement, retirement_in_market, down, down_in_market):
        self.date = date
        self.debt = debt
        self.retirement = retirement
        rm = retirement_in_market
        self.retirement_in_market = rm + rm * (0.06/12)
        self.down = down
        dm = down_in_market
        self.down_in_market = dm + dm * (0.03/12)

    def __str__(self):
        return "{DATE},{SD},{R},{RM},{DOWN},{DM}".format(
            DATE=self.date.isoformat(),
            SD=self.debt,
            R=self.retirement,
            RM=self.retirement_in_market,
            DOWN=self.down,
            DM=self.down_in_market
        )

loans = 121000
monthlydebt = 2000
retirement = 833
down = 2300
months = [Month(datetime(2018, 5, 1, 1, 1), loans, 24000, 24000, 0, 0)]

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
        previous.retirement_in_market + retirement,
        0, 0)
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
        previous.retirement_in_market + retirement,
        previous.down + down,
        previous.down_in_market + down)
    months.append(current)
    loans -= monthlydebt

csv = 'date, student_loans, retirement, down_payment\n{DATA}'.format(
    DATA='\n'.join([str(month) for month in months])
)

print(csv)
