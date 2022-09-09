function discounts = ratestodiscounts(dateSet, dates, rates)
% Calculation of the discounts having the zero rates
%
% INPUTS:
%  dateSet: settlement date
%  dates:   vector of dates
%  rates: vector of zero rates 
% 
% OUTPUTS:
%  discounts: vector of DFs 

%%
delta = yearfrac(dateSet,dates,3);
discounts = exp(-rates.*delta);

end
