function NPV = npvportfolio (discountCurve, portfolioData, fixingData, spotVol)

% compute the net present value for the portfolio
% 
% INPUT 
% discountCurve = discount curve with respect to the evaluation date 
% portfolioData = struct containing the various portfolio instrument data 
% fixingData = fixing libor data 
% spotVol = spot volatility surface
%
% OUTPUT
% NPV = portfolio net present value

%% Flag Model:
flagModel = spotVol.flagModel;

%% Swap prices:
priceSwaps = swappricing (discountCurve, portfolioData, fixingData);

%% Cap prices:
priceCaps = cappricing(discountCurve, portfolioData, fixingData,spotVol,flagModel);

%% Digital floor price:
priceDigital = digitalfloorprice(discountCurve, portfolioData, fixingData,spotVol, flagModel);

%% NPV:
NPV = sum(priceSwaps) + sum(priceCaps) + priceDigital;

end
