function price = vanillaCapFloorPrice(setDate, paymentDates, B, ...
    notional, vol, strike, flagModel, flagCF)
%
% Computes Cap or Floor price, giving a notional varying each year.

% INPUT
%
% setDate = settlement date for the cap / floor
% paymentDates = payment dates 
% B = discount curve 
% notional = notional for the cap/floor
% vol = spot for each caplets/floorlets
% strike = strike of the cap/floor
% flagModel = 0 normal and 1 for shifted black 
% flagCF = 'c' price a cap and 'f' price a floor

% OUTPUT
% price = price for the cap/floor 

act360 = 2;
dt = yearfrac([setDate; paymentDates(1:end-1)],paymentDates, act360);
B_fwd = B(2:end)./B(1:end-1);
L = (1./B_fwd - 1)./dt(2:end);

caplets = capletprice(B(2:end),L,setDate,paymentDates(1:end-1),...
    paymentDates(2:end), vol, strike,flagModel,flagCF);

price = notional * sum(caplets);
end
