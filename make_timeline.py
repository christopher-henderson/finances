from __future__ import division
from datetime import datetime


class Month(object):

    def __init__(self,
                 date,
                 debt,
                 no_market_retirement,
                 low_market_retirement,
                 avg_market_retirement,
                 high_market_retirement,
                 no_market_down,
                 low_market_down,
                 avg_market_down,
                 high_market_down,):
        self.date = date
        self.debt = debt
        self.no_market_retirement = no_market_retirement
        self.low_market_retirement = low_market_retirement
        self.avg_market_retirement = avg_market_retirement
        self.high_market_retirement = high_market_retirement
        self.no_market_down = no_market_down
        self.low_market_down = low_market_down
        self.avg_market_down = avg_market_down
        self.high_market_down = high_market_down
        # self.retirement = retirement
        # self.retirement_in_market = rm + rm * (0.06/12)
        # self.down = down
        # dm = down_in_market
        # self.down_in_market = dm + dm * (0.03/12)

    def __str__(self):
        return "{DATE},{SD},{NMR},{LMR},{AMR},{HMR},{NMD},{LMD},{AMD},{HMD}".format(
            DATE=self.date.isoformat(),
            SD=self.debt,
            NMR=self.no_market_retirement,
            LMR=self.low_market_retirement,
            AMR=self.avg_market_retirement,
            HMR=self.high_market_retirement,
            NMD=self.no_market_down,
            LMD=self.low_market_down,
            AMD=self.avg_market_down,
            HMD=self.high_market_down
        )

loans = 121000
monthlydebt = 2000
retirement = 833
down = 2300
months = [Month(datetime(2018, 5, 1, 1, 1), loans, 24000, 24000, 24000, 24000, 0, 0, 0, 0)]

taken = 0
while loans > 0:
    taken += 1
    previous = months[-1]
    month = (previous.date.month) % 12 + 1
    year = previous.date.year + previous.date.month // 12
    no_market_retirement = previous.no_market_retirement + retirement
    low_market_retirement = previous.low_market_retirement * (.03 / 12) + previous.low_market_retirement + retirement
    avg_market_retirement = previous.avg_market_retirement * (.06 / 12) + previous.avg_market_retirement + retirement
    high_market_retirement = previous.high_market_retirement * (.09 / 12) + previous.high_market_retirement + retirement
    current = Month(
        datetime(year, month, 1, 1, 1),
        previous.debt - monthlydebt,
        no_market_retirement,
        low_market_retirement,
        avg_market_retirement,
        high_market_retirement,
        0,
        0,
        0,
        0)
    months.append(current)
    loans -= monthlydebt

months[-1].down = -months[-1].debt
months[-1].debt = 0

for _ in range(5*12):
    previous = months[-1]
    month = (previous.date.month) % 12 + 1
    year = previous.date.year + previous.date.month // 12
    no_market_retirement = previous.no_market_down + retirement
    no_market_retirement = previous.no_market_retirement + retirement
    low_market_retirement = previous.low_market_retirement * (.03 / 12) + previous.low_market_retirement + retirement
    avg_market_retirement = previous.avg_market_retirement * (.06 / 12) + previous.avg_market_retirement + retirement
    high_market_retirement = previous.high_market_retirement * (.09 / 12) + previous.high_market_retirement + retirement
    no_market_down = previous.no_market_down + down
    low_market_down = previous.low_market_down * (.03 / 12) + previous.low_market_down + down
    avg_market_down = previous.avg_market_down * (.06 / 12) + previous.avg_market_down + down
    high_market_down = previous.high_market_down * (.09 / 12) + previous.high_market_down + down
    current = Month(
        datetime(year, month, 1, 1, 1),
        0,
        no_market_retirement,
        low_market_retirement,
        avg_market_retirement,
        high_market_retirement,
        no_market_down,
        low_market_down,
        avg_market_down,
        high_market_down)
    months.append(current)
    loans -= monthlydebt

csv = 'date, student_loans, no_market_retirement, low_market_retirement, avg_market_retirement, high_market_retirement, no_market_down, low_market_down, avg_market_down, high_market_down\n{DATA}'.format(
    DATA='\n'.join([str(month) for month in months])
)

print(csv)
