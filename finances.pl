:- use_module(library(clpr)).

budget_rent(
    Salary,
    PostTaxSalary,
    Taxes, MonthlyTaxes,
    Loans, MonthlyPayment, Rate, LoansAsAPercentageOfPostTax, Term,
    Rent, RentAsAPercentageOfPostTax,
    Retirement, MonthlyRetirement, RetirementAsAPercentageOfPreTax,
    DownPaymentContribution, MonthlyDownPaymentContribution, DownPaymentContributionAsAPercentageOfPostTax,
    Lifestyle, LifestyleAsAPercentageOfPostTax,
    Utilities, UtilitiesAsAPercentageOfPostTax,
    TakeHome,
    MonthlyExpenses,
    CurrentBalance, %CurrentBalance, always given.
    EmergencyFund, TimeToEmergencyFund) :-
  {MonthlyRetirement =  Retirement / 12},
  {RetirementAsAPercentageOfPreTax = Retirement / Salary},
  taxes(Taxes, Salary, Salary * RetirementAsAPercentageOfPreTax, 0, 0),
  {PostTaxSalary = Salary - Taxes},
  % Of course this is an average. The early months will be less and
  % the later months will be more.
  {MonthlyTaxes = Taxes / 12},
  % Term and rate is in years. Divided by 12 for monthly payments.
  {MonthlyPayment = (Rate * Loans) / (1 - (1 + Rate)^(-Term)) / 12},
  {LoansAsAPercentageOfPostTax = MonthlyPayment / (PostTaxSalary / 12)},
  {Rent = PostTaxSalary * RentAsAPercentageOfPostTax / 12},
  {MonthlyDownPaymentContribution = DownPaymentContribution / 12},
  {DownPaymentContributionAsAPercentageOfPostTax = DownPaymentContribution / PostTaxSalary},
  {Lifestyle = PostTaxSalary * LifestyleAsAPercentageOfPostTax / 12},
  {Utilities = PostTaxSalary * UtilitiesAsAPercentageOfPostTax / 12},
  {MonthlyExpenses = MonthlyPayment + Rent + MonthlyRetirement + Lifestyle + Utilities + MonthlyDownPaymentContribution},
  {TakeHome = PostTaxSalary / 12 - MonthlyExpenses},
  {EmergencyFund = MonthlyExpenses * 6},
  {TimeToEmergencyFund = (EmergencyFund - CurrentBalance) / TakeHome}.

budget_own(
    Salary,
    PostTaxSalary,
    Taxes, MonthlyTaxes,
    Loans, MonthlyPayment, Rate, LoansAsAPercentageOfPostTax, Term,
    Mortgage, MortgageRate, MortgageTerm, HomeValue, MortgageAsAPercentageOfPostTax, HOA,
    Retirement, RetirementAsAPercentageOfPreTax,
    Lifestyle, LifestyleAsAPercentageOfPostTax,
    Utilities, UtilitiesAsAPercentageOfPostTax,
    TakeHome,
    MonthlyExpenses,
    CurrentBalance, %CurrentBalance, always given.
    EmergencyFund, TimeToEmergencyFund) :-
  taxes(Taxes, Salary, Salary * RetirementAsAPercentageOfPreTax, HomeValue, MortgageRate),
  {PostTaxSalary = Salary - Taxes},
  % Of course this is an average. The early months will be less and
  % the later months will be more.
  {MonthlyTaxes = Taxes / 12},
  % Term and rate is in years. Divided by 12 for monthly payments.
  {MonthlyPayment = (Rate * Loans) / (1 - (1 + Rate)^(-Term)) / 12},
  {R = MortgageRate / 12},
  {N = MortgageTerm * 12},
  {PMI = HomeValue * 0.005 / 12}, % Assuming that I cannot escape PMI at the moment.
  {Mortgage = HOA + PMI + HomeValue * ((R*(1 + R)^N)/((1 + R)^N - 1))},
  % {Mortgage = (MortgageRate * HomeValue) / (1 - (1 + MortgageRate)^(-MortgageTerm)) / 12},
  {MortgageAsAPercentageOfPostTax = Mortgage / PostTaxSalary},
  {LoansAsAPercentageOfPostTax = MonthlyPayment / (PostTaxSalary / 12)},
  {Retirement = Salary * RetirementAsAPercentageOfPreTax / 12 + 5500 / 12},
  {Lifestyle = PostTaxSalary * LifestyleAsAPercentageOfPostTax / 12},
  {Utilities = PostTaxSalary * UtilitiesAsAPercentageOfPostTax / 12},
  {MonthlyExpenses = MonthlyPayment + Mortgage + Retirement + Lifestyle + Utilities},
  {TakeHome = PostTaxSalary / 12 - MonthlyExpenses},
  {EmergencyFund = MonthlyExpenses * 6},
  {TimeToEmergencyFund = (EmergencyFund - CurrentBalance) / TakeHome}.

taxes(Taxes, Salary, TaxAdvantagedRetirement, HomeValue, MortgageRate) :-
  federal_taxes(Federal, Salary, TaxAdvantagedRetirement, HomeValue, MortgageRate),
  california_taxes(California, Salary, HomeValue),
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
federal_taxes(Taxes, Salary, TaxAdvantagedRetirement, 0, 0) :-
  {AdjustedIncome = Salary - TaxAdvantagedRetirement - 630}, % Standard deduction.
  social_security(SS, AdjustedIncome),
  medicare(Medicare, AdjustedIncome),
  federal_taxes_(IncomeTaxes, AdjustedIncome),
  {Taxes = SS + Medicare + IncomeTaxes}.
federal_taxes(Taxes, Salary, TaxAdvantagedRetirement, HomeValue, MortgageRate) :-
  {MortgageInterest = HomeValue * MortgageRate},
  {PropertyTaxes = HomeValue * 0.00701},
  federal_taxes_(Taxes, Salary - TaxAdvantagedRetirement - MortgageInterest - PropertyTaxes). % Standard deduction.
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

% 2017 Tax Law
% https://www.irs.gov/publications/p15/ar02.html#en_US_2017_publink1000202367
%
% For 2017, the social security tax rate is 6.2% (amount withheld)
% each for the employer and employee (12.4% total). The social security wage
% base limit is $127,200. The tax rate for Medicare is 1.45% (amount withheld)
% each for the employee and employer (2.9% total). There is no wage base limit
% for Medicare tax; all covered wages are subject to Medicare tax.
social_security(SS, Income):-
  {Income =< 127200},
  {SS = Income * 0.062}.
social_security(SS, Income):-
  {WageLimitedIncome = Income - (Income - 127200)},
  {SS = WageLimitedIncome * 0.062}.
medicare(Medicare, Income):-
  {Medicare = Income * 0.0145}.


% 2016 tax brackets from
% https://smartasset.com/taxes/california-tax-calculator
california_taxes(Taxes, Salary, 0) :-
  california_disability_tax(DisabilityTaxes, Salary),
  california_taxes_(IncomeTaxes, Salary),
  {Taxes = IncomeTaxes + DisabilityTaxes}.
california_taxes(Taxes, Salary, HomeValue) :-
  california_disability_tax(DisabilityTaxes, Salary),
  {PropertyTaxes = HomeValue * 0.00701},
  california_taxes_(IncomeTaxes, Salary),
  {Taxes = IncomeTaxes + PropertyTaxes + DisabilityTaxes}.
california_taxes_(Taxes, Salary) :- {Salary =< 7850}, !,
                        {Taxes = Salary * 0.01}.
california_taxes_(Taxes, Salary) :- {Salary =< 18610}, !,
                        california_taxes_(ProgressiveTaxes, 7850),
                        {Taxes = ProgressiveTaxes + (Salary - 7850) * 0.02}.
california_taxes_(Taxes, Salary) :- {Salary =< 29372}, !,
                        california_taxes_(ProgressiveTaxes, 18610),
                        {Taxes = ProgressiveTaxes + (Salary - 18610) * 0.04}.
california_taxes_(Taxes, Salary) :- {Salary =< 40773}, !,
                        california_taxes_(ProgressiveTaxes, 29372),
                        {Taxes = ProgressiveTaxes + (Salary - 29372) * 0.06}.
california_taxes_(Taxes, Salary) :- {Salary =< 51530}, !,
                        california_taxes_(ProgressiveTaxes, 40773),
                        {Taxes = ProgressiveTaxes + (Salary - 40773) * 0.08}.
california_taxes_(Taxes, Salary) :- {Salary =< 263222}, !,
                        california_taxes_(ProgressiveTaxes, 51530),
                        {Taxes = ProgressiveTaxes + (Salary - 51530) * 0.093}.
california_taxes_(Taxes, Salary) :- {Salary =< 315866}, !,
                        california_taxes_(ProgressiveTaxes, 263222),
                        {Taxes = ProgressiveTaxes + (Salary - 263222) * 0.1030}.
california_taxes_(Taxes, Salary) :- {Salary =< 526443}, !,
                        california_taxes_(ProgressiveTaxes, 315866),
                        {Taxes = ProgressiveTaxes + (Salary - 315866) * 0.1130}.
california_taxes_(Taxes, Salary) :- {Salary > 526443}, !,
                        california_taxes_(ProgressiveTaxes, 526443),
                        {Taxes = ProgressiveTaxes + (Salary - 526443) * 0.1230}.

california_disability_tax(Taxes, Salary) :- {Taxes = Salary * 0.009}.
