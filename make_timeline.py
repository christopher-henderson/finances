from __future__ import division
from datetime import datetime


class Month(object):

    def __init__(self,
                 date,
                 student_loans,
                 retirment,
                 down_payment):
        self.date = date
        self.student_loans = student_loans
        self.retirement = retirment
        self.down_payment = down_payment

    def copy(self, date):
        return Month(
            date,
            self.student_loans.copy(),
            self.retirement.copy(),
            self.down_payment.copy())

    def __str__(self):
        return "{DATE},{SD},{NMR},{LMR},{AMR},{HMR},{NMD},{LMD},{AMD},{HMD}".format(
            DATE=self.date.isoformat(),
            SD=self.student_loans.principle,
            NMR=self.retirement.no_market,
            LMR=self.retirement.low_market,
            AMR=self.retirement.avg_market,
            HMR=self.retirement.high_market,
            NMD=self.down_payment.no_market,
            LMD=self.down_payment.low_market,
            AMD=self.down_payment.avg_market,
            HMD=self.down_payment.high_market
            )


class StudentLoan(object):

    def __init__(self, principle, rate):
        self.principle = principle
        self.rate = rate

    def calculate(self, payment):
        # Or is it the other way around?
        self.principle -= payment
        self.principle += self.principle * (self.rate / 12)

    def copy(self):
        return StudentLoan(self.principle, self.rate)

    def __lt__(self, value):
        return self.principle < value

    def __gt__(self, value):
        return self.principle > value

    def __ge__(self, value):
        return self.principle >= value

    def __le__(self, value):
        return self.principle <= value

    def __eq__(self, value):
        return self.principle == value


class Investment(object):

    LOW = 0.03
    AVG = 0.06
    HIGH = 0.09

    def __init__(self, principle):
        self.no_market = principle
        self.low_market = principle
        self.avg_market = principle
        self.high_market = principle

    def contribute(self, contribution):
        self.no_market += contribution
        self.low_market += self.low_market * (self.LOW / 12) + contribution
        self.avg_market += self.avg_market * (self.AVG / 12) + contribution
        self.high_market += self.high_market * (self.HIGH / 12) + contribution

    def copy(self):
        copy = Investment(0)
        copy.no_market = self.no_market
        copy.low_market = self.low_market
        copy.avg_market = self.avg_market
        copy.high_market = self.high_market
        return copy


class Timeline(object):

    def __init__(self, date, student_loans, rate, retirement, down_payment):
        self.student_loans = StudentLoan(student_loans, rate)
        self.retirement = Investment(retirement)
        self.down_payment = Investment(down_payment)
        self.months = [
            Month(
                date,
                self.student_loans.copy(),
                self.retirement.copy(),
                self.down_payment.copy()
                )
            ]

    def build(
            self,
            goal,
            spillage,
            monthly_loans_payment,
            monthly_retirement_contribution,
            monthly_down_payment_contribution):
        previous = self.months[-1]
        months = 0
        while goal(months, previous):
            month = (previous.date.month) % 12 + 1
            year = previous.date.year + previous.date.month // 12

            new = previous.copy(datetime(year, month, 1, 1, 1))
            new.student_loans.calculate(monthly_loans_payment)
            new.retirement.contribute(monthly_retirement_contribution)
            new.down_payment.contribute(monthly_down_payment_contribution)

            self.months.append(new)
            months += 1
            spillage(new)
            previous = new

    def csv(self):
        return 'date, student_loans, no_market_retirement, low_market_retirement, avg_market_retirement, high_market_retirement, no_market_down, low_market_down, avg_market_down, high_market_down\n{DATA}'.format(
            DATA='\n'.join([str(month) for month in self.months])
            )

def spill(month):
    if month.student_loans < 0:
        month.down_payment.no_market += -month.student_loans.principle
        month.down_payment.low_market += -month.student_loans.principle
        month.down_payment.avg_market += -month.student_loans.principle
        month.down_payment.high_market += -month.student_loans.principle
        month.student_loans.principle = 0


timeline = Timeline(datetime(2018, 5, 1, 1, 1), 121000, 0.048, 24700, 0)
timeline.build(
    lambda months, month: month.student_loans > 0,
    spill,
    2282, 833, 0,
    )
timeline.build(
    lambda months, month: month.date.year <= 2028,
    lambda _: True,
    0, 833, 2282,
    )
print(timeline.csv())

# timeline2 = Timeline(datetime(2018, 5, 1, 1, 1), 121000, 0.048, 24700, 0)
# timeline2.build(
#     lambda months, month: month.student_loans > 0,
#     lambda _: True,
#     2000, 833, 0,
#     )
# timeline2.build(
#     lambda months, month: month.date.year <= 2028,
#     spill,
#     0, 833, 2000,
#     )
#
# timeline3 = Timeline(datetime(2018, 5, 1, 1, 1), 121000, 0.048, 24700, 0)
# timeline3.build(
#     lambda months, month: month.student_loans > 62000,
#     lambda _: True,
#     2000, 833, 0,
#     )
# timeline3.build(
#     lambda months, month: month.date.year <= 2028,
#     spill,
#     1149, 833, 851,
#     )
#
# timeline4 = Timeline(datetime(2018, 5, 1, 1, 1), 121000, 0.048, 24700, 0)
# timeline4.build(
#     lambda months, month: month.date.year <= 2028,
#     spill,
#     664, 833, 1336,
#     )
# print(timeline.csv().split('\n')[-1])
# print(timeline2.csv().split('\n')[-1])
# print(timeline3.csv().split('\n')[-1])
# print(timeline4.csv().split('\n')[-1])
