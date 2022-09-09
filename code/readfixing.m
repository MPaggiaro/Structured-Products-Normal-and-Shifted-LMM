function fixingData = readfixing (filename, formatData)
% 
% INPUT 
%
% helper function to read the excel file contaning the fixing 
% filename = name of the file containing the fixings 
% formatData = the data format of the desired output 
% 
% OUTPUT 
% fixingData = struct contaning all the infos used for computations

% We select the fixings starting from the 2nd of january 2015.

[~,dates] = xlsread(filename,1,'E4104:E4436');
fixingData.dates = datenum(dates, formatData);
fixingData.rates = xlsread(filename,1,'F4104:F4436');
end
