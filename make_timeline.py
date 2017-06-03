from __future__ import division
from datetime import datetime


class Month(object):

    def __init__(self,
                 date,
                 student_loans,
                 no_market_retirement,
                 low_market_retirement,
                 avg_market_retirement,
                 high_market_retirement,
                 no_market_down,
                 low_market_down,
                 avg_market_down,
                 high_market_down,):
        self.date = date
        self.student_loans = student_loans
        self.no_market_retirement = no_market_retirement
        self.low_market_retirement = low_market_retirement
        self.avg_market_retirement = avg_market_retirement
        self.high_market_retirement = high_market_retirement
        self.no_market_down = no_market_down
        self.low_market_down = low_market_down
        self.avg_market_down = avg_market_down
        self.high_market_down = high_market_down

    def __str__(self):
        return "{DATE},{SD},{NMR},{LMR},{AMR},{HMR},{NMD},{LMD},{AMD},{HMD}".format(
            DATE=self.date.isoformat(),
            SD=self.student_loans,
            NMR=self.no_market_retirement,
            LMR=self.low_market_retirement,
            AMR=self.avg_market_retirement,
            HMR=self.high_market_retirement,
            NMD=self.no_market_down,
            LMD=self.low_market_down,
            AMD=self.avg_market_down,
            HMD=self.high_market_down
            )


class Timeline(object):

    def __init__(self, date, student_loans, retirement, down_payment):
        self.months = [
            Month(
                date,
                student_loans,
                retirement, retirement, retirement, retirement,
                down_payment, down_payment, down_payment, down_payment)
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

            new_student_loan = previous.student_loans - monthly_loans_payment

            no_market_retirement = previous.no_market_retirement + monthly_retirement_contribution
            low_market_retirement = previous.low_market_retirement * (.03 / 12) + previous.low_market_retirement + monthly_retirement_contribution
            avg_market_retirement = previous.avg_market_retirement * (.06 / 12) + previous.avg_market_retirement + monthly_retirement_contribution
            high_market_retirement = previous.high_market_retirement * (.09 / 12) + previous.high_market_retirement + monthly_retirement_contribution

            no_market_down = previous.no_market_down + monthly_down_payment_contribution
            low_market_down = previous.low_market_down * (.03 / 12) + previous.low_market_down + monthly_down_payment_contribution
            avg_market_down = previous.avg_market_down * (.06 / 12) + previous.avg_market_down + monthly_down_payment_contribution
            high_market_down = previous.high_market_down * (.09 / 12) + previous.high_market_down + monthly_down_payment_contribution

            previous = Month(
                datetime(year, month, 1, 1, 1),
                new_student_loan,
                no_market_retirement,
                low_market_retirement,
                avg_market_retirement,
                high_market_retirement,
                no_market_down,
                low_market_down,
                avg_market_down,
                high_market_down)

            self.months.append(previous)
            months += 1
        spillage(previous)

    def csv(self):
        return 'date, student_loans, no_market_retirement, low_market_retirement, avg_market_retirement, high_market_retirement, no_market_down, low_market_down, avg_market_down, high_market_down\n{DATA}'.format(
            DATA='\n'.join([str(month) for month in self.months])
            )

timeline = Timeline(datetime(2018, 5, 1, 1, 1), 121000, 24700, 0)
timeline.build(
    lambda months, month: month.student_loans >= 60000,
    lambda _: True,
    2000, 833, 0,
    )
timeline.build(
    lambda months, month: months / 12 < 8,
    lambda _: True,
    318, 833, 1698,
    )
print(timeline.csv())
