function spreadPrice = capspreadprice(discountCurve, portfolioData, fixingData,spotVol)
% 
% price the cap spread to hedge the digital risk in the portfolio 
% 
% INPUT
% discountCurve = discount curve used for pricing 
% portfolioData = struct contaning portfolio data 
% spotVol = struct of the spot volatilities, can be normal or shifted
% 
% OUTPUT 
% spreadPrice = price of the cap spread

%% Extraction of the flag model:
flagModel = spotVol.flagModel;

%% Computation of the price:
epsilon = 1e-4;
% We select a difference of 1bp between the strikes of the two caps.
% We go long in the cap with strike equal to the strike of the digital
% floor, while we go short in the cap with strike equal to:
% strikeDigital + 1bp.

% payoff of the digital:
digPayoff = portfolioData.digFloor.payoff;

set = discountCurve.dates(1);
setDigital = portfolioData.digFloor.settlement;

payDatesDig = dateMoveVec(setDigital,'m',portfolioData.paymentDates(1:length(portfolioData.digFloor.notionals)),'MF',eurCalendar);
index = find(payDatesDig > set,1);

% dates and discounts are the same for the two caps:
t0 = payDatesDig(index-1);
dates = payDatesDig(index:end);
discounts = extractdiscount (discountCurve, dates);

% The notionals of the cap spread would be the same notionals of the
% digital floor, rescaled by the digital payoff and multiplied by the
% inverse of a basis point:
notionals = digPayoff/epsilon * portfolioData.digFloor.notionals(index:end);

% Strikes of the two caps forming the cap spread:
strike1 = portfolioData.digFloor.rate -0.5*epsilon;
strike2 = strike1 + 0.5*epsilon;

% Extraction of the fixing (it's thw same for the two caps:
fixingDate = dateMoveVec(t0,'d',-1,'MF',eurCalendar);
libor_3m_t0 = getfixing(fixingData, fixingDate)/100;

% Selection of the volatilities of interest:
vol = interp2(spotVol.strikes,spotVol.paymentDates,...
    spotVol.surface,[strike1, strike2],dates(2:end), 'spline');

vol1 = vol(:,1);
vol2 = vol(:,2);

price1 = capfloorprice (discounts, libor_3m_t0, t0,set, dates,...
    notionals, vol1, strike1, flagModel, 'c');

price2 = capfloorprice (discounts, libor_3m_t0, t0,set, dates,...
    notionals, vol2, strike2, flagModel, 'c');

spreadPrice = price1 - price2;

end
