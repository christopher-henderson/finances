:- use_module(library(clpr)).

budget(
    Salary,
    PostTaxSalary,
    Taxes, MonthlyTaxes,
    Rent, RentAsAPercentageOfPostTax,
    Retirement, RetirementAsAPercentageOfPreTax,
    Groceries, GroceriesAsAPercentageOfPostTax,
    Utilities, UtilitiesAsAPercentageOfPostTax,
    TakeHome,
    MonthlyExpenses,
    CurrentBalance, %CurrentBalance, always given.
    EmergencyFund, TimeToEmergencyFund) :-
  taxes(Taxes, Salary, Salary * RetirementAsAPercentageOfPreTax),
  {PostTaxSalary = Salary - Taxes},
  % Of course this is an average. The early months will be less and
  % the later months will be more.
  {MonthlyTaxes = Taxes / 12},
  {Rent = PostTaxSalary * RentAsAPercentageOfPostTax / 12},
  {Retirement = Salary * RetirementAsAPercentageOfPreTax / 12},
  {Groceries = PostTaxSalary * GroceriesAsAPercentageOfPostTax / 12},
  {Utilities = PostTaxSalary * UtilitiesAsAPercentageOfPostTax / 12},
  {MonthlyExpenses = Rent + Retirement + Groceries + Utilities},
  {TakeHome = PostTaxSalary / 12 - MonthlyExpenses},
  {EmergencyFund = MonthlyExpenses * 6},
  {TimeToEmergencyFund = (EmergencyFund - CurrentBalance) / TakeHome}.


taxes(Taxes, Salary, TaxAdvantagedRetirement) :-
  federal_taxes(Federal, Salary, TaxAdvantagedRetirement),
  california_taxes(California, Salary),
  {Taxes = Federal + California}.

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
federal_taxes(Taxes, Salary, TaxAdvantagedRetirement) :- federal_taxes_(Taxes, Salary - TaxAdvantagedRetirement - 6300). % Standard deduction.
federal_taxes_(Taxes, Salary) :- {Salary =< 9275}, !,
                        {Taxes = Salary * 0.10}.
federal_taxes_(Taxes, Salary) :- {Salary =< 37650}, !,
                        federal_taxes_(ProgressiveTaxes, 9275),
                        {Taxes = ProgressiveTaxes + (Salary - 9275) * 0.15}.
federal_taxes_(Taxes, Salary) :- {Salary =< 91150}, !,
                        federal_taxes_(ProgressiveTaxes, 37650),
                        {Taxes = ProgressiveTaxes + (Salary - 37650) * 0.25}.
federal_taxes_(Taxes, Salary) :- {Salary =< 190150}, !,
                        federal_taxes_(ProgressiveTaxes, 91150),
                        {Taxes = ProgressiveTaxes + (Salary - 91150) * 0.28}.
federal_taxes_(Taxes, Salary) :- {Salary =< 413350}, !,
                        federal_taxes_(ProgressiveTaxes, 190150),
                        {Taxes = ProgressiveTaxes + (Salary - 190,150) * 0.33}.
federal_taxes_(Taxes, Salary) :- {Salary =< 415050}, !,
                        federal_taxes_(ProgressiveTaxes, 413350),
                        {Taxes = ProgressiveTaxes + (Salary - 413350) * 0.35}.
federal_taxes_(Taxes, Salary) :- {Salary > 415050}, !,
                        federal_taxes_(ProgressiveTaxes, 415050),
                        {Taxes = ProgressiveTaxes + (Salary - 415050) * 0.396}.

% 2016 tax brackets from
% https://smartasset.com/taxes/california-tax-calculator
california_taxes(Taxes, Salary) :- {Salary =< 7850}, !,
                        {Taxes = Salary * 0.01}.
california_taxes(Taxes, Salary) :- {Salary =< 18610}, !,
                        california_taxes(ProgressiveTaxes, 7850),
                        {Taxes = ProgressiveTaxes + (Salary - 7850) * 0.02}.
california_taxes(Taxes, Salary) :- {Salary =< 29372}, !,
                        california_taxes(ProgressiveTaxes, 18610),
                        {Taxes = ProgressiveTaxes + (Salary - 18610) * 0.04}.
california_taxes(Taxes, Salary) :- {Salary =< 40773}, !,
                        california_taxes(ProgressiveTaxes, 29372),
                        {Taxes = ProgressiveTaxes + (Salary - 29372) * 0.06}.
california_taxes(Taxes, Salary) :- {Salary =< 51530}, !,
                        california_taxes(ProgressiveTaxes, 40773),
                        {Taxes = ProgressiveTaxes + (Salary - 40773) * 0.08}.
california_taxes(Taxes, Salary) :- {Salary =< 263222}, !,
                        california_taxes(ProgressiveTaxes, 51530),
                        {Taxes = ProgressiveTaxes + (Salary - 51530) * 0.093}.
california_taxes(Taxes, Salary) :- {Salary =< 315866}, !,
                        california_taxes(ProgressiveTaxes, 263222),
                        {Taxes = ProgressiveTaxes + (Salary - 263222) * 0.1030}.
california_taxes(Taxes, Salary) :- {Salary =< 526443}, !,
                        california_taxes(ProgressiveTaxes, 315866),
                        {Taxes = ProgressiveTaxes + (Salary - 315866) * 0.1130}.
california_taxes(Taxes, Salary) :- {Salary > 526443}, !,
                        california_taxes(ProgressiveTaxes, 526443),
                        {Taxes = ProgressiveTaxes + (Salary - 526443) * 0.1230}.
