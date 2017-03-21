:- use_module(library(clpr)).

budget(
    Salary,
    Taxes, MonthlyTaxes,
    Loans, YearsToRepayment, MonthlyPayment, LoansAsAPercentageOfPreTax,
    Rent, RentAsAPercentageOfPreTax,
    Retirement, RetirementAsAPercentageOfPreTax,
    Groceries, GroceriesAsAPercentageOfPreTax,
    Utilities, UtilitiesAsAPercentageOfPreTax,
    TakeHome,
    MonthlyExpenses,
    CurrentBalance, %CurrentBalance, always given.
    EmergencyFund, TimeToEmergencyFund) :-
  taxes(Taxes, Salary),
  % Of course this is an average. The early months will be less and
  % the later months will be more.
  {MonthlyTaxes = Taxes / 12},
  {MonthlyPayment = (Loans / YearsToRepayment) / 12},
  {LoansAsAPercentageOfPreTax = MonthlyPayment / (Salary / 12)},
  {Rent = Salary * RentAsAPercentageOfPreTax / 12},
  {Retirement = Salary * RetirementAsAPercentageOfPreTax / 12},
  {Groceries = Salary * GroceriesAsAPercentageOfPreTax / 12},
  {Utilities = Salary * UtilitiesAsAPercentageOfPreTax / 12},
  {MonthlyExpenses = MonthlyPayment + Rent + Retirement + Groceries + Utilities},
  {TakeHome = Salary / 12 - MonthlyExpenses},
  {EmergencyFund = MonthlyExpenses * 6},
  {TimeToEmergencyFund = (EmergencyFund - CurrentBalance) / TakeHome}.

% 2016 Tax Brackets From:
% https://www.nerdwallet.com/blog/taxes/federal-income-tax-brackets/
%
% $0 to $9,275	10%
% $9,276 to $37,650	$927.50 plus 15% of the amount over $9,275
% $37,650 to $91,150	$5,183.75 plus 25% of the amount over $37,650
% $91,150 to $190,150	$18,558.75 plus 28% of the amount over $91,150
% $190,150 to $413,350	$46,278.75 plus 33% of the amount over $190,150
% $413,350 to $415,050	$119,934.75 plus 35% of the amount over $413,350
% $415,050 or more	$120,529.75 plus 39.6% of the amount over $415,050
%
taxes(Taxes, Salary) :- {Salary < 9275}, !,
                        {Taxes = Salary * 0.10}.
taxes(Taxes, Salary) :- {Salary < 37650}, !,
                        {Taxes = 927.5 + (Salary - 9275) * 0.15}.
taxes(Taxes, Salary) :- {Salary < 91150}, !,
                        {Taxes = 5183.75 + (Salary - 37650) * 0.25}.
taxes(Taxes, Salary) :- {Salary < 190150}, !,
                        {Taxes = 18558.75 + (Salary - 91150) * 0.28}.
taxes(Taxes, Salary) :- {Salary < 413350}, !,
                        {Taxes = 46278.75 + (Salary - 190,150) * 0.33}.
taxes(Taxes, Salary) :- {Salary < 415050}, !,
                        {Taxes = 119934.75 + (Salary - 413350) * 0.35}.
taxes(Taxes, Salary) :- {Salary > 415050}, !,
                        {Taxes = 120529.75 + (Salary - 415050) * 0.396}.
