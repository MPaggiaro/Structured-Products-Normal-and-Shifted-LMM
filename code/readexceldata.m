function [dates, rates, volatilityData] = readexceldata( filename, formatData)
% Reads data from excel
%  All input rates are in % units
%
% INPUTS:
%  filename: excel file name where data is stored
%  formatData: data format in Excel
% 
% OUTPUTS:
%  dates: struct with settlementDate, deposDates, futuresDates, swapDates
%  rates: struct with deposRates, futuresRates, swapRates



%% 1) Rates
%Depos
depoRates = xlsread(filename, 1, 'J80:J88');
rates.depos = depoRates / 100;


%Swaps
swapRates = xlsread(filename, 1, 'O80:O94');
rates.swaps = swapRates / 100;

%% 2) Dates

%Settlement date
[~, settlement] = xlsread(filename, 1, 'C2');
%Date conversion
dates.settlement = datenum(settlement, formatData);

%Dates relative to depos
dates.depos = zeros(size(rates.depos));
% We construct the dates:
dates.depos(1) = dateMoveVec(dates.settlement, 'd',1,'MF',eurCalendar);
dates.depos(2:3) = dateMoveVec(dates.settlement, 'w',1:2,'MF',eurCalendar);
dates.depos(4:end) = dateMoveVec(dates.settlement,'m',[1 2 3 6 9 12],'MF',eurCalendar);

%Date relative to swaps:
year_swaps = [1:10 12 15:5:30]; 
dates.swaps = dateMoveVec(dates.settlement,'y',year_swaps,'MF',eurCalendar);


%% Volatility Data:
%% Strikes and maturities:
% Cap Maturities
volatilityData.maturities = xlsread(filename, 1, 'f4:f14');
% Cap strikes
volatilityData.strikes= xlsread(filename, 1, 'k2:w2')/100;

%% Normal LMM:
% Vol for ATM Cap
volatilityData.normal.atm = xlsread(filename, 1, 'j23:j33')/100;
% flat Vol Surface
volatilityData.normal.surface = xlsread(filename, 1, 'k23:w33')/10000;

volatilityData.normal.atmStrikes = xlsread(filename, 1, 'i23:i33')/100;

%% Shifted LMM:
% Vol for ATM Cap
volatilityData.shifted.atm = xlsread(filename, 1, 'j4:j14')/100;
% flat Vol Surface
volatilityData.shifted.surface = xlsread(filename, 1, 'k4:w14')/100;

volatilityData.shifted.atmStrikes = xlsread(filename, 1, 'i4:i14')/100;

end