function priceCaps = cappricing(discountCurve, portfolioData, fixingData,spotVol, flagModel)
% 
% price all the caps in the portfolio 
% 
% INPUT
% discountCurve = the discount curve wrt evaluation date 
% portfolioData = struct containing data relative to caps & floors in the portfolio
% fixingData = data used to retrieve the last libor fixing before the ev. date 
% flagModel = 0 for the normal 1 for the shifted black
% OUTPUT
% priceCaps = prices for the caps in the portfolio

% Selection of the payments of interest:
set = discountCurve.dates(1);
nCaps = 4; % number of caps.
priceCaps = zeros(nCaps,1);
for i = 1:nCaps
    setCap = portfolioData.caps.settlements(i);
    payDatesCaps = dateMoveVec(setCap,'m',portfolioData.paymentDates,'MF',eurCalendar);
    % find the first payment date after the settlement date:
    index = find(payDatesCaps > set, 1);
    
    t0 = payDatesCaps(index-1);
    dates = payDatesCaps(index:end);
    discounts = extractdiscount (discountCurve, dates);
    notionals = portfolioData.caps.notionals(index:end,i);
    
    strike = portfolioData.caps.rates(i);
    % flagCF tells us if we're dealing with a cap or with a floor.
    flagCF = portfolioData.caps.flagCap(i);
    % flagLS tells us if we are buying (i.e long position) or selling (i.e. short
    % position the cap/floor.
    flagLS = portfolioData.caps.flagLong(i);
    
    % Extraction of the fixing:
    fixingDate = dateMoveVec(t0,'d',-1,'MF',eurCalendar);
    libor_3m_t0 = getfixing(fixingData, fixingDate)/100;
    
    % Selection of the volatilities of interest:
    capVolatilities = interp2(spotVol.strikes,spotVol.paymentDates,...
        spotVol.surface,strike,dates(2:end), 'spline');
    switch flagLS
        case 'l'
            priceCaps(i) = capfloorprice (discounts, libor_3m_t0, t0, set, dates,...
                notionals, capVolatilities, strike, flagModel, flagCF);
        case 's'
            priceCaps(i) = - capfloorprice (discounts, libor_3m_t0, t0, set, dates,...
                notionals, capVolatilities, strike, flagModel, flagCF);     
    end
end



end
