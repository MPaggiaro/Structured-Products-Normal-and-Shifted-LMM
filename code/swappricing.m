function priceSwaps = swappricing (discountCurve, portfolioData, fixingData)
%
% Selection of the payments of interest:
% 
% INPUT 
% discountCurve = curve used for discounting 
% portfolioData = struct containing data for the various portfolio instruments 
% fixingData = data for the libor fixings
% 
% OUTPUT
% priceSwaps = price for each swap in the assigned portfolio
set = discountCurve.dates(1);

NumSwaps = 2; % number of swaps.
priceSwaps = zeros(NumSwaps,1);
for i = 1:NumSwaps
    setSwap = portfolioData.swaps.settlements(i);
    payDatesSwaps = dateMoveVec(setSwap,'m',portfolioData.paymentDates,'MF',eurCalendar);
    % find the first payment date after the settlement date:
    index = find(payDatesSwaps > set, 1);
    
    t0 = payDatesSwaps(index-1);
    dates = payDatesSwaps(index:end);
    discounts = extractdiscount (discountCurve, dates);
    notionals = portfolioData.swaps.notionals(index:end,i);
    
    swap_rate = portfolioData.swaps.rates(i);
    flag = portfolioData.swaps.flagPayer(i);
    
    % Extraction of the fixing:
    %????? is it one or two days earlier???????
    fixingDate = dateMoveVec(t0,'d',-1,'MF',eurCalendar);
    liborFixing = getfixing(fixingData, fixingDate)/100;
    
    priceSwaps(i) = swapformularolling(t0, liborFixing, notionals, ...
        dates, discounts, swap_rate, flag);
end

end
