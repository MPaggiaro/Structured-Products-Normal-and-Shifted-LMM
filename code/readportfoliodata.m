function portfolioData = readportfoliodata (filename, formatData)
% Reads data from excel
%  All input rates are in % units
%
% INPUTS:
%  filename: excel file name where data is stored
%  formatData: data format in Excel
% 
% OUTPUTS:
%  portfolioData: struct containing the information of the portfolio.

%% Payment Dates (in months):
portfolioData.paymentDates = (3:3:120)';


%% Swap data:
[~,setSwap] = xlsread(filename,'B6:C6');
portfolioData.swaps.settlements = datenum(setSwap, formatData);
portfolioData.swaps.rates = xlsread(filename,'B8:C8');
portfolioData.swaps.flagPayer = ['p'; 'r'];
tempSwap = xlsread(filename,'B11:C30');
% We double the vector (we want notionals for trimesters and not semesters:
portfolioData.swaps.notionals = zeros(2*size(tempSwap,1),size(tempSwap,2));
for i = 1 : size(tempSwap,1)
    % if you find a NaN, save it as zero:
    for j = 1:size(tempSwap,2)
       if isnan(tempSwap(i,j))
           tempSwap(i,j) = 0;
       end
    end
    portfolioData.swaps.notionals(2*i-1,:) = tempSwap(i,:);
    portfolioData.swaps.notionals(2*i,:) = tempSwap(i,:);
end

%% Cap data:
[~,dates] = xlsread(filename,'D6:I6');
portfolioData.caps.settlements = datenum(dates([1:3,6]), formatData);

portfolioData.caps.flagCap = ['c';'c';'f';'f'];
portfolioData.caps.flagLong = ['s';'l';'l';'l'];

rates = xlsread(filename,'D8:I8');
portfolioData.caps.rates = rates([1:3,6]);

tempCap = xlsread(filename,'D11:F30');
% We double the vector (we want notionals for trimesters and not semesters:
portfolioData.caps.notionals = zeros(2*size(tempCap,1),size(tempCap,2)+1);
for i = 1 : size(tempCap,1)
    % if you find a NaN, save it as zero:
    for j = 1:size(tempCap,2)
       if isnan(tempCap(i,j))
           tempCap(i,j) = 0;
       end
    end
    portfolioData.caps.notionals(2*i-1,1:end-1) = tempCap(i,:);
    portfolioData.caps.notionals(2*i,1:end-1) = tempCap(i,:);
end

portfolioData.caps.notionals(:,end) = xlsread(filename,'I11:I50');



%% Digital Floor data:

portfolioData.digFloor.settlement = datenum(dates(4), formatData);
portfolioData.digFloor.rate = rates(4);
portfolioData.digFloor.payoff = xlsread(filename,1,'G9');

tempDig = xlsread(filename,'G11:G15');
portfolioData.digFloor.notionals = zeros(2*length(tempDig),1);
for i = 1 : length(tempDig)
    portfolioData.digFloor.notionals(2*i-1,:) = tempDig(i,:);
    portfolioData.digFloor.notionals(2*i,:) = tempDig(i,:);
end


end



