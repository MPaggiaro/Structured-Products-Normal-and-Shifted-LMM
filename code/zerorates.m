function y = zerorates(dates, discounts)
% Calculation of the zero rate through the formula
%
% INPUTS:
%  dates: vector of dates, the first one is the settlement, the others are
%         expiries.
%  discounts: vector of discounts. 
% 
% OUTPUTS:
%  zRates: zero rates 

delta = yearfrac(dates(1),dates(2:end),3);
y = -log(discounts(2:end))./delta;

end
