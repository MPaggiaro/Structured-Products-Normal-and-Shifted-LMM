% % Final Project group 11.

clear all
close all
clc

%% Read market data & Bootstrap:
formatData='dd/mm/yyyy';
[datesSet, ratesSet, volatilityData] = readexceldata('IRVol', formatData);

discountCurve = bootstrap(datesSet, ratesSet);

%% Portfolio Data:
portfolioData = readportfoliodata('Portfolio_Project11',formatData);

%% Fixings: 
% we save historical fixings vs Euribor3m.
% The first date we use is 2nd of january 2015.
fixingData = readfixing('historicalEuriborFixings',formatData);

%% Bootstrap of the spot volatilities:
spotVolNormal  = getspotvolatilities( volatilityData, discountCurve, portfolioData, 'normal');
spotVolShifted  = getspotvolatilities( volatilityData, discountCurve, portfolioData, 'shifted');

%% Point A: portfolio NPV.

NPVnormal = npvportfolio (discountCurve, portfolioData, fixingData, spotVolNormal);
NPVshift = npvportfolio (discountCurve, portfolioData, fixingData, spotVolShifted);


%% Point B: hedge portfolio.
[priceHedge_shift, nSwaps_shift, nCaps_shift] = hedgeportfolio (discountCurve, portfolioData, ...
    fixingData, spotVolShifted);

[priceHedge_normal, nSwaps_normal, nCaps_normal] = hedgeportfolio (discountCurve, portfolioData, ...
    fixingData, spotVolNormal);

%% Point C: steepen portfolio.
[~, nSwaps_shift_steep, ~] = steepenportfolio (discountCurve, portfolioData, ...
    fixingData, spotVolShifted);

[~,nSwaps_normal_steep, ~] = steepenportfolio (discountCurve, portfolioData, ...
    fixingData, spotVolNormal);


%% Point D: digital risk.
% Hedging the digital floor with a cap spread:
spreadPriceNormal = capspreadprice(discountCurve, portfolioData, fixingData,spotVolNormal);
spreadPriceShifted = capspreadprice(discountCurve, portfolioData, fixingData,spotVolShifted);
