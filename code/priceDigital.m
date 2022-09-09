function [priceBlack,priceSmile]=priceDigital(cSelect, notional, ...
                            optionPayoff, optionStrike, optionTTM, discount)
% computes the price of the digital option with Black's model and with Implied volatility approach
%
% INPUTS:
% cSelect: struct of my dataset for volatility smile
% notional: derivative's notional
% optionPayoff: percentuage of the notional pay back
% optionStrike: thereshould to have a no-zero payoff
% optionTTM: time to maturity of my option
% discount: discount at TTM
% 
% OUTPUTS:
% priceBlack: price of my digital option computed with Black's model
% priceSmile: price of my digital option computed with implied volatility approach
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%% Black's model  
volatility=spline(cSelect.strikes,cSelect.surface,optionStrike); %cubic interpolation
d2=-.5*(sqrt(optionTTM)*volatility); %ATM option
priceBlack=discount*normcdf(d2)*notional*optionPayoff/100; % price from Black's model
 
%% Implied volatility approach
epsilon=1; %increment of the strike
strike_eps=optionStrike+epsilon; 
volatility_eps=spline(cSelect.strikes,cSelect.surface,strike_eps); %volatility at strike+epsilon
SlopeImpact=(volatility_eps-volatility)/epsilon; % difference quotient
rate=-log(discount)/optionTTM; %rate at maturity
vega=blsvega(cSelect.reference,optionStrike,rate,optionTTM,volatility,...
                cSelect.dividends);
priceSmile=(discount*normcdf(d2)-SlopeImpact*vega)*notional*optionPayoff/100;
end