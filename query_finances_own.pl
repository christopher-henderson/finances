#!/usr/bin/env swipl --quiet

:- initialization main.


main :-
  [finances],
  Salary = 120000,
  Loans = 114000,
  Rate = 0.048, Term = 25,
  HomeValue = 800000, MortgageRate = 0.06375, MortgageTerm = 30,
  RetirementAsAPercentageOfPreTax = 0.04,
  GroceriesAsAPercentageOfPostTax = 0.10,
  UtilitiesAsAPercentageOfPostTax = 0.02,
  % TimeToEmergencyFund = 6,
  CurrentBalance = 11000,
  budget_own(
      Salary, PostTaxSalary,
      Taxes, MonthlyTaxes,
      Loans, MonthlyPayment, Rate, LoansAsAPercentageOfPostTax, Term,
      Mortgage, MortgageRate, MortgageTerm, HomeValue, MortgageAsAPercentageOfPostTax,
      Retirement, RetirementAsAPercentageOfPreTax,
      Groceries, GroceriesAsAPercentageOfPostTax,
      Utilities, UtilitiesAsAPercentageOfPostTax,
      TakeHome,
      MonthlyExpenses,
      CurrentBalance,
      EmergencyFund, TimeToEmergencyFund),
  write("Salary: "), write(Salary), nl,
  write("PostTaxSalary: "), write(PostTaxSalary), nl,
  write("Taxes: "), write(Taxes), nl,
  write("MonthlyTaxes: "), write(MonthlyTaxes), nl,
  write("Loans: "), write(Loans), nl,
  write("LoansAsAPercentageOfPostTax: "), write(LoansAsAPercentageOfPostTax), nl,
  write("YearsToRepayment: "), write(Term), nl,
  write("MonthlyPayment: "), write(MonthlyPayment), nl,
  write("Mortgage: "), write(Mortgage), nl,
  write("MortgageAsAPercentageOfPostTax: "), write(MortgageAsAPercentageOfPostTax), nl,
  write("Retirement: "), write(Retirement), nl,
  write("RetirementAsAPercentageOfPreTax: "), write(RetirementAsAPercentageOfPreTax), nl,
  write("Groceries: "), write(Groceries), nl,
  write("GroceriesAsAPercentageOfPostTax: "), write(GroceriesAsAPercentageOfPostTax), nl,
  write("Utilities: "), write(Utilities), nl,
  write("UtilitiesAsAPercentageOfPostTax: "), write(UtilitiesAsAPercentageOfPostTax), nl,
  write("TakeHome: "), write(TakeHome), nl,
  write("MonthlyExpenses: "), write(MonthlyExpenses), nl,
  write("CurrentBalance: "), write(CurrentBalance), nl,
  write("EmergencyFund: "), write(EmergencyFund), nl,
  write("TimeToEmergencyFund: "), write(TimeToEmergencyFund), nl,
  halt.
