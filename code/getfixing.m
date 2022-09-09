function fixing = getfixing(fixingData, date)
%
% getFixing selects a fixing Euribor3m associated to a date from the database
% fixingData.
%
% INPUTS:
%  fixingData: struct of fixings
%  date: date in which you want to compute the fixing
%
% OUTPUTS:
%  fixing: fixing of the date.

index = find(fixingData.dates == date,1);

fixing = fixingData.rates(index);

end

