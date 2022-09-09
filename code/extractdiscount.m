function DF = extractdiscount (discountCurve, date)
% Function that computes the DF's associated to the vector of dates given
% as input.
% 
% OUTPUTs:
% DF: vector of discount factors B(t0,ti), where ti = date(i).
% 
% INPUTS:
% t0: settlement date
% dates: vector of expiry dates
% discounts: vector of DF's obtained with bootstrap technique.
%
% WARNING: the bootstrap's settlement date must be equal to t0.

% First control: check if settlements dates are the same.
% if (t0 ~= bootstrap_dates(1))
%     error('WARNING: the bootstrap settlement date must be equal to t0!');
% end

N = length(date);
DF = zeros(N,1);

% We now extract DF from the bootstrap.
for i = 1:N
    % First index where bootstrap dates are smaller or equal than the date
    % we are considering. The parameter 1 stands for "give me the first".
    
    % If the date exists among the bootstrap_dates, then we have the DF:
    if ismember(date(i),discountCurve.dates)
        DF(i) = discountCurve.DF(discountCurve.dates == date(i));
    % Else we interpolate between the two dates of the bootstrap next to it
    else
        DF(i) = interpolation(discountCurve.dates,discountCurve.DF,date(i));
    end
end
end