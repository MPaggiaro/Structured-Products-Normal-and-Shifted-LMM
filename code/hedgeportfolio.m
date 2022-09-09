function [priceHedge, swapNotionals, capNotionals] = hedgeportfolio (discountCurve, portfolioData, ...
    fixingData, spotVolData)

% hedge the protfolio 

% INPUT
% discountCurve = discount curve used for the portfolio 
% portfolioData = struct contaning the relevant data for the instruments in the portfolio 
% fixingData = data for the fixing of the libor 
% spotVolData = struct contanining the selected model type (normal or shifted ) and the relative volatility surface 
% bucketYear = bucket to shift the volatility on 
% flagModel = 0 for normal and 1 for shifted black 

% OUTPUT
% priceHedge = price for the hedging strategy 
% swapNotionals = notional amount for the swaps used for hedging 
% capNotionals =  notional amount for the caps/floors used for hedging 

% discount
flagModel = spotVolData.flagModel;

flagCF = 'f';
% Buckets of the portfolio:
bucketYears = [2;4;7;10];

%% Computation of the delta and the vega of the original portfolio in the four buckets:
deltaPortfolio = zeros(size(bucketYears));
vegaPortfolio = zeros(size(bucketYears));

for i = 1:length(bucketYears)
    deltaPortfolio(i) = getportfolioDV01 (discountCurve, portfolioData, ...
        fixingData, spotVolData, bucketYears(i));
    vegaPortfolio(i) = getportfoliovega (discountCurve, portfolioData, ...
        fixingData, spotVolData, bucketYears(i));
end

%% Computation of the swap rates:
act360 = 2;
setDate = discountCurve.dates(1);
dates = dateMoveVec(setDate,'m',portfolioData.paymentDates,'MF',eurCalendar);
discounts = extractdiscount(discountCurve,dates);
delta =  yearfrac([setDate;dates(1:end-1)],dates,act360);

swapRates = zeros(size(bucketYears));
for i = 1 : length(bucketYears)
    swapRates(i) = swaprate(discounts(1:4*bucketYears(i)), delta(1:4*bucketYears(i)));
end

%% computation of the delta and vegas of caps and swaps of the hedging portfolio:

% deltaCaps is the matrix of the deltas of the caps of the hedging
% portfolio. deltaSwaps is the one for the swaps.
% Rows: deltas in a given bucket
% Columns: deltas in the four buckets for a given cap with a given
% maturity.

priceCaps = zeros(size(bucketYears));
deltaCaps = zeros(length(bucketYears));
deltaSwaps = zeros(length(bucketYears));
vegaCaps = zeros(length(bucketYears));


% First cycle is on the buckets we are evaluating
for i = 1 : length(bucketYears)    
    % Extraction of the shifted curve in the i-th bucket:
    shiftedCurve = forwardshift(discountCurve, bucketYears(i));
    shiftedDiscounts = extractdiscount(shiftedCurve,dates);
    
    % shifted surface of the volatilities in the i-th bucket:
    shiftedSpotVol = volatilityshift(spotVolData, bucketYears(i));

    % Second cicle is, given a bucket, on the products we have.
    for j = 1 : length(bucketYears)    
        paymentDates = dates(1:4*bucketYears(j));
        B = discounts(1:4*bucketYears(j));
        Bshift = shiftedDiscounts(1:4*bucketYears(j));
        
        % Selection of the volatilities of interest:
        capVolatilities = interp2(spotVolData.strikes,spotVolData.paymentDates,...
            spotVolData.surface, swapRates(j), paymentDates(2:end), 'spline');
        
        [priceCaps(j), deltaCaps(i,j)] = dv01vanillaCap (setDate, paymentDates, B, Bshift,...
            1, capVolatilities, swapRates(j), flagModel, flagCF);
        deltaSwaps(i,j) = dv01Swap(setDate, paymentDates, B, Bshift,1, swapRates(j),'p');
        
        if j >= i 
            shiftVols = interp2(shiftedSpotVol.strikes,shiftedSpotVol.paymentDates,...
                shiftedSpotVol.surface, swapRates(j), paymentDates(2:end), 'spline');
            vegaCaps (i,j) = vegaVanillaCap(B, setDate, paymentDates, ...
               1, capVolatilities, shiftVols, swapRates(j), flagModel, flagCF); 
        end
    end
end

%% Vega of the portfolio equal to zero:
% The linear system in order to find the notionals for the caps is:
% vegaCaps * x = - vegaPortfolio, where x is the vector of the notionals of
% caps.

% Ax = v: x = A\v.
capNotionals = -vegaCaps\vegaPortfolio;

%% Delta of the portfolio equal to zero:
% In this case, the linear system for setting the delta equal to zero in
% all buckets is:
% deltaPortfolio + deltaSwaps*y + deltaCaps*x = 0, where:
% x = capNotionals (already found)
% y = swapNotionals (unknown).
% Hence we find an explicit formula for y:
swapNotionals = deltaSwaps\(-deltaPortfolio - deltaCaps*capNotionals);

%% Price of the hedge portfolio:

% Since swap prices are zero, they don't make a contribution in the price
% of the hedge.
priceHedge = dot(capNotionals,priceCaps);

end
