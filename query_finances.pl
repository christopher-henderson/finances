#!/usr/bin/env swipl --quiet

:- initialization main.


main :-
  [finances],
  Salary = 120000,
  Loans = 114000,
  LoansAsAPercentageOfPreTax = 0.20,
  RentAsAPercentageOfPreTax = 0.35,
  RetirementAsAPercentageOfPreTax = 0.06,
  GroceriesAsAPercentageOfPreTax = 0.10,
  CurrentBalance = 11000,
  budget(
      Salary,
      Taxes, MonthlyTaxes,
      Loans, YearsToRepayment, MonthlyPayment, LoansAsAPercentageOfPreTax,
      Rent, RentAsAPercentageOfPreTax,
      Retirement, RetirementAsAPercentageOfPreTax,
      Groceries, GroceriesAsAPercentageOfPreTax,
      TakeHome,
      MonthlyExpenses,
      CurrentBalance,
      EmergencyFund, TimeToEmergencyFund),
  write("Salary: "), write(Salary), nl,
  write("Taxes: "), write(Taxes), nl,
  write("MonthlyTaxes: "), write(MonthlyTaxes), nl,
  write("Loans: "), write(Loans), nl,
  write("LoansAsAPercentageOfPreTax: "), write(LoansAsAPercentageOfPreTax), nl,
  write("YearsToRepayment: "), write(YearsToRepayment), nl,
  write("MonthlyPayment: "), write(MonthlyPayment), nl,
  write("Rent: "), write(Rent), nl,
  write("RentAsAPercentageOfPreTax: "), write(RentAsAPercentageOfPreTax), nl,
  write("Retirement: "), write(Retirement), nl,
  write("RetirementAsAPercentageOfPreTax: "), write(RetirementAsAPercentageOfPreTax), nl,
  write("Groceries: "), write(Groceries), nl,
  write("GroceriesAsAPercentageOfPreTax: "), write(GroceriesAsAPercentageOfPreTax), nl,
  write("TakeHome: "), write(TakeHome), nl,
  write("MonthlyExpenses: "), write(MonthlyExpenses), nl,
  write("CurrentBalance: "), write(CurrentBalance), nl,
  write("EmergencyFund: "), write(EmergencyFund), nl,
  write("TimeToEmergencyFund: "), write(TimeToEmergencyFund), nl,
  halt.
