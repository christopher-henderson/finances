:- use_module(library(clpr)).

budget_rent(
    Salary,
    PostTaxSalary,
    Taxes, Federal, California, MonthlyTaxes,
    Loans, MonthlyPayment, Rate, LoansAsAPercentageOfPostTax, Term,
    Rent, RentAsAPercentageOfPostTax,
    Retirement, MonthlyRetirement, RetirementAsAPercentageOfPreTax,
    DownPaymentContribution, MonthlyDownPaymentContribution, DownPaymentContributionAsAPercentageOfPostTax,
    Lifestyle, LifestyleAsAPercentageOfPostTax,
    Utilities, UtilitiesAsAPercentageOfPostTax,
    TakeHome,
    MonthlyExpenses,
    CurrentBalance,
    EmergencyFund, TimeToEmergencyFund) :-
  {MonthlyRetirement =  Retirement / 12},
  {RetirementAsAPercentageOfPreTax = Retirement / Salary},
  {RetirementContrubutions = Salary * RetirementAsAPercentageOfPreTax},
  taxes(Taxes, Federal, California, Salary, RetirementContrubutions, 0, 0),
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
    Taxes, Federal, California, MonthlyTaxes,
    Loans, MonthlyPayment, Rate, LoansAsAPercentageOfPostTax, Term,
    Mortgage, MortgageRate, MortgageTerm, HomeValue, MortgageAsAPercentageOfPostTax, HOA,
    Retirement, MonthlyRetirement, RetirementAsAPercentageOfPreTax,
    Lifestyle, LifestyleAsAPercentageOfPostTax,
    Utilities, UtilitiesAsAPercentageOfPostTax,
    TakeHome,
    MonthlyExpenses,
    CurrentBalance, %CurrentBalance, always given.
    EmergencyFund, TimeToEmergencyFund) :-
  taxes(Taxes, Federal, California, Salary, Salary * RetirementAsAPercentageOfPreTax, HomeValue, MortgageRate),
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
  {RetirementAsAPercentageOfPreTax = Retirement / Salary},
  {MonthlyRetirement = Retirement / 12},
  {Lifestyle = PostTaxSalary * LifestyleAsAPercentageOfPostTax / 12},
  {Utilities = PostTaxSalary * UtilitiesAsAPercentageOfPostTax / 12},
  {MonthlyExpenses = MonthlyPayment + Mortgage + Retirement + Lifestyle + Utilities},
  {TakeHome = PostTaxSalary / 12 - MonthlyExpenses},
  {EmergencyFund = MonthlyExpenses * 6},
  {TimeToEmergencyFund = (EmergencyFund - CurrentBalance) / TakeHome}.

taxes(Taxes, Federal, California, Salary, TaxAdvantagedRetirement, HomeValue, MortgageRate) :-
  california_taxes(California, Salary, HomeValue),
  itemized(California, 12200, Deduction),
  {FedSalary = Salary - Deduction},
  federal_taxes(Federal, FedSalary, TaxAdvantagedRetirement, HomeValue, MortgageRate),
  {Taxes = Federal + California}.

itemized(State, StandardDeduction, Deduction) :- State > StandardDeduction, Deduction = State.
itemized(State, StandardDeduction, Deduction) :- State < StandardDeduction, Deduction = StandardDeduction. %% Standard Deduction

%% 2019 Federal Tax Brackets
%% 10% $0 to $9,700  10% of taxable income
%% 12% $9,701 to $39,475 $970 plus 12% of the amount over $9,700
%% 22% $39,476 to $84,200  $4,543 plus 22% of the amount over $39,475
%% 24% $84,201 to $160,725 $14,382.50 plus 24% of the amount over $84,200
%% 32% $160,726 to $204,100  $32,748.50 plus 32% of the amount over $160,725
%% 35% $204,101 to $510,300  $46,628.50 plus 35% of the amount over $204,100
%% 37% $510,301 or more  $153,798.50 plus 37% of the amount over $510,300

federal_taxes(Taxes, Salary, TaxAdvantagedRetirement, 0, 0) :-
  {AdjustedIncome = Salary - TaxAdvantagedRetirement},
  social_security(SS, AdjustedIncome),
  medicare(Medicare, AdjustedIncome),
  federal_taxes_(IncomeTaxes, AdjustedIncome),
  {Taxes = SS + Medicare + IncomeTaxes}.
federal_taxes(Taxes, Salary, TaxAdvantagedRetirement, HomeValue, MortgageRate) :-
  {MortgageInterest = HomeValue * MortgageRate},
  {PropertyTaxes = HomeValue * 0.00701},
  federal_taxes_(Taxes, Salary - TaxAdvantagedRetirement - MortgageInterest - PropertyTaxes). % Standard deduction.

federal_taxes_(Taxes, Salary) :- {Salary =< 9700}, !,
                        {Taxes = Salary * 0.10}.
federal_taxes_(Taxes, Salary) :- {Salary =< 39475}, !,
                        federal_taxes_(ProgressiveTaxes, 9700),
                        {Taxes = ProgressiveTaxes + (Salary - 9700) * 0.12}.
federal_taxes_(Taxes, Salary) :- {Salary =< 84200}, !,
                        federal_taxes_(ProgressiveTaxes, 39475),
                        {Taxes = ProgressiveTaxes + (Salary - 39475) * 0.22}.
federal_taxes_(Taxes, Salary) :- {Salary =< 160725}, !,
                        federal_taxes_(ProgressiveTaxes, 84200),
                        {Taxes = ProgressiveTaxes + (Salary - 84200) * 0.24}.
federal_taxes_(Taxes, Salary) :- {Salary =< 204100}, !,
                        federal_taxes_(ProgressiveTaxes, 160725),
                        {Taxes = ProgressiveTaxes + (Salary - 160725) * 0.32}.
federal_taxes_(Taxes, Salary) :- {Salary =< 510300}, !,
                        federal_taxes_(ProgressiveTaxes, 204100),
                        {Taxes = ProgressiveTaxes + (Salary - 204100) * 0.35}.
federal_taxes_(Taxes, Salary) :- {Salary > 510300}, !,
                        federal_taxes_(ProgressiveTaxes, 510300),
                        {Taxes = ProgressiveTaxes + (Salary - 510300) * 0.37}.

% 2017 Tax Law
% https://www.irs.gov/publications/p15/ar02.html#en_US_2017_publink1000202367
%
% For 2017, the social security tax rate is 6.2% (amount withheld)
% each for the employer and employee (12.4% total). The social security wage
% base limit is $127,200. The tax rate for Medicare is 1.45% (amount withheld)
% each for the employee and employer (2.9% total). There is no wage base limit
% for Medicare tax; all covered wages are subject to Medicare tax.
social_security(SS, Income):-
  {Income =< 132900},
  {SS = Income * 0.062}.
social_security(SS, Income):-
  {WageLimitedIncome = Income - (Income - 132900)},
  {SS = WageLimitedIncome * 0.062}.
medicare(Medicare, Income):-
  {Medicare = Income * 0.0145}.


%% 2019 California
%% $0.00+  1%
%% $8,223.00+  2%
%% $19,495.00+   3%
%% $30,769.00+   4%
%% $42,711.00+   8%
%% $53,980.00+   9.3%
%% $275,738.00+  10.3%
%% $330,884.00+  11.3%
%% $551,473.00+  12.3%
%% $1,000,000.00+  13.3% 
california_taxes(Taxes, Salary, 0) :-
  california_disability_tax(DisabilityTaxes, Salary),
  california_taxes_(IncomeTaxes, Salary),
  {Taxes = IncomeTaxes + DisabilityTaxes}.
california_taxes(Taxes, Salary, HomeValue) :-
  california_disability_tax(DisabilityTaxes, Salary),
  {PropertyTaxes = HomeValue * 0.00701},
  california_taxes_(IncomeTaxes, Salary),
  {Taxes = IncomeTaxes + PropertyTaxes + DisabilityTaxes}.
california_taxes_(Taxes, Salary) :- {Salary =< 8223}, !,
                        {Taxes = Salary * 0.01}.
california_taxes_(Taxes, Salary) :- {Salary =< 19495}, !,
                        california_taxes_(ProgressiveTaxes, 8223),
                        {Taxes = ProgressiveTaxes + (Salary - 8223) * 0.02}.
california_taxes_(Taxes, Salary) :- {Salary =< 30769}, !,
                        california_taxes_(ProgressiveTaxes, 9495),
                        {Taxes = ProgressiveTaxes + (Salary - 9495) * 0.03}.
california_taxes_(Taxes, Salary) :- {Salary =< 42711}, !,
                        california_taxes_(ProgressiveTaxes, 30769),
                        {Taxes = ProgressiveTaxes + (Salary - 30769) * 0.04}.
california_taxes_(Taxes, Salary) :- {Salary =< 53980}, !,
                        california_taxes_(ProgressiveTaxes, 42711),
                        {Taxes = ProgressiveTaxes + (Salary - 42711) * 0.08}.
california_taxes_(Taxes, Salary) :- {Salary =< 275738}, !,
                        california_taxes_(ProgressiveTaxes, 53980),
                        {Taxes = ProgressiveTaxes + (Salary - 53980) * 0.093}.
california_taxes_(Taxes, Salary) :- {Salary =< 330884}, !,
                        california_taxes_(ProgressiveTaxes, 275738),
                        {Taxes = ProgressiveTaxes + (Salary - 275738) * 0.1030}.
california_taxes_(Taxes, Salary) :- {Salary =< 551473}, !,
                        california_taxes_(ProgressiveTaxes, 330884),
                        {Taxes = ProgressiveTaxes + (Salary - 330884) * 0.1130}.
california_taxes_(Taxes, Salary) :- {Salary =< 1000000}, !,
                        california_taxes_(ProgressiveTaxes, 551473),
                        {Taxes = ProgressiveTaxes + (Salary - 551473) * 0.1230}.
california_taxes_(Taxes, Salary) :- {Salary > 1000000}, !,
                        california_taxes_(ProgressiveTaxes, 1000000),
                        {Taxes = ProgressiveTaxes + (Salary - 1000000) * 0.1330}.

california_disability_tax(Taxes, Salary) :- {Taxes = Salary * 0.009}.


