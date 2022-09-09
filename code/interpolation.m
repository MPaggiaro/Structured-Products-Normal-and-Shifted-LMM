function B = interpolation(dates,discounts,t)
%
% Function that compute the discount factor B through the linear interpolation in d 
% between the two interest rates B1, B2 respectively at d1 and d2 
%
% INPUTS (tbm): 
% set : settlement date
% d1  : fist date of the interpolation ?????????????????
% d   : date of interest ???????????????
% d2  : second date of the interpolation
% B1  : discount factor at d1
% B2  : discount factor at d2
%
% OUTPUTS:
% B  : discount factor in d

%conversion from the discount factors to the zero rates:
zeroRates = zerorates(dates,discounts);

%interpolation
y =  interp1(dates(2:end),zeroRates,t);

%conversion brom the zero rate to the discount factor
delta = yearfrac(dates(1),t,3);
B = exp(-(delta* y));
end