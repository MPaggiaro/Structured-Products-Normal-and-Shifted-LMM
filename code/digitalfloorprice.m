function price = digitalfloorprice(discountCurve, portfolioData, fixingData,spotVol, flagModel)
%
% Computes Cap or Floor price, giving a notional varying each year.
%
% INPUTS:
% B = deterministic discount
% L = libor 
% notional 
% vol = model volatility
% strikes 
% flagModel 
%      0 if normal LMM
%      1 if shifted LMM
% digital_payoff = percentage on the notional
% OUTPUTS:
% price = price of the digital floorlet

set = discountCurve.dates(1);
setDigital = portfolioData.digFloor.settlement;

payDatesDig = dateMoveVec(setDigital,'m',portfolioData.paymentDates(1:length(portfolioData.digFloor.notionals)),'MF',eurCalendar);
index = find(payDatesDig > set,1);
    
t0 = payDatesDig(index-1);
dates = payDatesDig(index:end);
discounts = extractdiscount (discountCurve, dates);
notionals = portfolioData.digFloor.notionals(index:end);
strike = portfolioData.digFloor.rate;

% Extraction of the fixing:
fixingDate = dateMoveVec(t0,'d',-1,'MF',eurCalendar);
libor_3m_t0 = getfixing(fixingData, fixingDate)/100;

% Selection of the volatilities of interest:
splineVol = interp2(spotVol.strikes,spotVol.paymentDates,...
    spotVol.surface,[spotVol.strikes, strike],dates(2:end), 'spline');
volatilities = splineVol(:,end);

% We want now to find the slope of the volatility with respect to the
% strike price, for every maturity date of the floorlets payment. 
slopes = zeros(size(volatilities));
for i = 1 : length(slopes)
   sigma_ti = spline(spotVol.strikes,splineVol(i, 1:end-1));
   slopes(i) = ppval(fnder(sigma_ti),strike);
end

floorlets = zeros(size(notionals));

act360 = 2;
dt = yearfrac([t0; dates(1:end-1)],dates, act360);
B_fwd = discounts(2:end)./discounts(1:end-1);
L = (1./B_fwd - 1)./dt(2:end);


% Computation of the price of the floorlets:
floorlets(1) = discounts(1)*dt(1)*(libor_3m_t0 > strike);
floorlets(2:end) = digitalfloorletprice(discounts(2:end),L,set,dates(1:end-1),...
    dates(2:end), volatilities, strike, slopes, flagModel);
price = portfolioData.digFloor.payoff * dot(notionals, floorlets);
end
