#!/usr/bin/env swipl --quiet

:- initialization main.


main :-
  [finances],
  Salary = 120000,
  Loans = 121000,
  Rate = 0.0428, Term = 7,
  Rent = 2100,
  Retirement = 10000,
  DownPaymentContribution = 0,
  Lifestyle = 1022,
  Utilities = 150,
  CurrentBalance = 11000,
  budget_rent(
      Salary, PostTaxSalary,
      Taxes, MonthlyTaxes,
      Loans, MonthlyPayment, Rate, LoansAsAPercentageOfPostTax, Term,
      Rent, RentAsAPercentageOfPostTax,
      Retirement, MonthlyRetirement, RetirementAsAPercentageOfPreTax,
      DownPaymentContribution, MonthlyDownPaymentContribution, DownPaymentContributionAsAPercentageOfPostTax,
      Lifestyle, LifestyleAsAPercentageOfPostTax,
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
  write("Rent: "), write(Rent), nl,
  write("RentAsAPercentageOfPostTax: "), write(RentAsAPercentageOfPostTax), nl,
  write("Retirement: "), write(Retirement), nl,
  write("MonthlyRetirement: "), write(MonthlyRetirement), nl,
  write("RetirementAsAPercentageOfPreTax: "), write(RetirementAsAPercentageOfPreTax), nl,
  write("DownPaymentContribution: "), write(DownPaymentContribution), nl,
  write("MonthlyDownPaymentContribution: "), write(MonthlyDownPaymentContribution), nl,
  write("DownPaymentContributionAsAPercentageOfPostTax: "), write(DownPaymentContributionAsAPercentageOfPostTax), nl,
  write("Lifestyle: "), write(Lifestyle), nl,
  write("LifestyleAsAPercentageOfPostTax: "), write(LifestyleAsAPercentageOfPostTax), nl,
  write("Utilities: "), write(Utilities), nl,
  write("UtilitiesAsAPercentageOfPostTax: "), write(UtilitiesAsAPercentageOfPostTax), nl,
  write("TakeHome: "), write(TakeHome), nl,
  write("MonthlyExpenses: "), write(MonthlyExpenses), nl,
  write("CurrentBalance: "), write(CurrentBalance), nl,
  write("EmergencyFund: "), write(EmergencyFund), nl,
  write("TimeToEmergencyFund: "), write(TimeToEmergencyFund), nl,
  halt.
