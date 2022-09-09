function  spotVolData  = getspotvolatilities( volatilityData, discountCurve, portfolioData, flagModel)
% Computes spot volatilities from the the flat volatility
% INPUTS :
% volatilityData: struct containing data of the flat volatility
% discountCurve: struct containing the discount curve (with relative dates)
%
% OUTPUTS :
% capletVolatilities: matrix of the spot volatility surface

spotVolData.flagModel = flagModel;

act360 = 2;

%% Parameters
setDate = discountCurve.dates(1);   % settlement date
T = dateMoveVec(setDate,'m',portfolioData.paymentDates,'MF',eurCalendar);

B = extractdiscount(discountCurve, [setDate; T]);
yearFrac = yearfrac([setDate; T(1:end-1)], T, act360);

nMaturities = length(volatilityData.maturities); % number of maturities
nDates = length(discountCurve.dates)-1;   % number of payment dates
nStrikes = length(volatilityData.strikes);       % number of strikes

% Note that nDates = 4 * nMaturities. If this doesn't hold, the code won't
% work.

% surface of flat volatilities
switch flagModel
    case 'normal'
        flatVolatilities = volatilityData.normal.surface;    
    case 'shifted'
        flatVolatilities = volatilityData.shifted.surface;              
end
strike = volatilityData.strikes;              % strikes
spotVolData.strikes = strike;
% flag tells us if we're using normal or shifted LMM.

 
%% Caps

B_fwd = B(2:end)./B(1:end-1); 
L = (1./B_fwd - 1 )./yearFrac; % Forward interest rate 

capPrices = zeros(nMaturities,nStrikes); %n_dates-1 perch� prima data in payment dates � fixing date primo caplet

spotVolData.paymentDates = T(2:end); % the first trimester doesn't pay.
for k = 1 : nStrikes
    for j = 1 : nMaturities  
        if j == 1
            caplets = capletprice(B(2:4),L(1:3),setDate,T(1:3),T(2:4),flatVolatilities(j,k), strike(k),flagModel,'c');
        elseif j == 2
            caplets = capletprice(B(2:6),L(1:5),setDate,T(1:5),T(2:6),flatVolatilities(j,k), strike(k),flagModel,'c');    
        else
            years = j-1; 
            caplets = capletprice(B(2:4*years),L(1:4*years-1),setDate,T(1:4*years-1),T(2:4*years),flatVolatilities(j,k), strike(k),flagModel,'c');
        end
        capPrices(j,k) = sum(caplets);
    end
end

%% compute caplet volatilities

spotVolData.surface = zeros(nDates-1, nStrikes); % first tenor is not considered.
spotVolData.surface(1,:) = flatVolatilities(1,:); % volatility first year
spotVolData.surface(2,:) = flatVolatilities(1,:); % volatility 2nd year
spotVolData.surface(3,:) = flatVolatilities(1,:); % volatility 3rd year

for k=1:nStrikes    
    % qui ho siccome i caplets sono trimestrali faccio salti da 4
    
    % for the first two caps I have a semestral price.
    for j = 1 : 2
        % times:
        % semesters s:
        s = j + 1;
        T_alpha = T(2*s);
        T_1 = T(2*s+1);
        T_beta = T(2*s+2);
        
        % discounts:
        B_1 = B(2*s+1);
        B_beta = B(2*s+2);
        
        deltaAlpha1 = yearfrac(T_alpha,T_1,act360);
        deltaAlphaBeta = yearfrac(T_alpha,T_beta,act360);
        
        sigmaAlpha = spotVolData.surface(2*s-1,k); 
        
        sigma1 = @(sigmaBeta) sigmaAlpha + deltaAlpha1/deltaAlphaBeta* (sigmaBeta - sigmaAlpha);
        
        deltaCap = capPrices(j+1,k) - capPrices(j,k);  % Delta Cap from flat volatilities
        cplSum = @(sigmaBeta)      capletprice(B_1,    L(2*s),   setDate, T_alpha,   T_1,    sigma1(sigmaBeta),    strike(k),  flagModel, 'c') + ...
                                    capletprice(B_beta,    L(2*s+1), setDate, T_1 ,  T_beta,    sigmaBeta,    strike(k),  flagModel, 'c');
        
        zeroFun = @(sigmaBeta)     cplSum(sigmaBeta) - deltaCap; % find zero of this function
        x0 = 0.2; % initial Guess           
        sigmaBeta = fzero(zeroFun,x0); %find the zero of Zero_fun
        
        %% backsubstitution
        spotVolData.surface(2*s,k) = sigma1(sigmaBeta);
        spotVolData.surface(2*s+1,k) = sigmaBeta;
    end
    
    % From the third to the end I have annual prices.
    for j = 2 : nMaturities - 2  
       T_alpha = T(4*j);
       T_1 = T(4*j+1);
       T_2 = T(4*j+2);
       T_3 = T(4*j+3);
       T_beta = T(4*(j+1));
       
       % discounts:
       B_1 = B(4*j+1);
       B_2 = B(4*j+2);
       B_3 = B(4*j+3);
       B_beta = B(4*(j+1));

       %% sigma functions 
       deltaAlpha1 = yearfrac(T_alpha,T_1,act360);
       deltaAlpha2 = yearfrac(T_alpha,T_2,act360);
       deltaAlpha3 = yearfrac(T_alpha,T_3,act360);
       deltaAlphaBeta = yearfrac(T_alpha,T_beta,act360);
       
       sigmaAlpha = spotVolData.surface(4*j-1,k); 
       
       % 4 VOLs to be found... set up the first three constraint for the
       % non linear system
       sigma1 = @(sigmaBeta) sigmaAlpha + deltaAlpha1/deltaAlphaBeta* (sigmaBeta - sigmaAlpha);
       sigma2 = @(sigmaBeta) sigmaAlpha + deltaAlpha2/deltaAlphaBeta* (sigmaBeta - sigmaAlpha);
       sigma3 = @(sigmaBeta) sigmaAlpha + deltaAlpha3/deltaAlphaBeta* (sigmaBeta - sigmaAlpha);

       %% The fourth constraint is obtained by setting the sum of caplets equal to the delta_cap
   
       deltaCap = capPrices(j+2,k) - capPrices(j+1,k);  % Delta Cap from flat volatilities
       cplSum = @(sigmaBeta)      capletprice(B_1,    L(4*j),   setDate, T_alpha,   T_1,    sigma1(sigmaBeta),    strike(k),  flagModel, 'c') + ...
                                    capletprice(B_2,    L(4*j+1), setDate, T_1 ,      T_2,    sigma2(sigmaBeta),    strike(k),  flagModel, 'c') + ... 
                                    capletprice(B_3,    L(4*j+2), setDate, T_2 ,      T_3,    sigma3(sigmaBeta),    strike(k),  flagModel, 'c') + ...
                                    capletprice(B_beta, L(4*j+3), setDate, T_3 ,      T_beta, sigmaBeta,             strike(k),  flagModel, 'c');
                            
       zeroFun = @(sigmaBeta)     cplSum(sigmaBeta) - deltaCap; % find zero of this function
       x0 = 0.2; % initial Guess           
       sigmaBeta = fzero(zeroFun,x0); %find the zero of Zero_fun
       
       %% backsubstitution
       spotVolData.surface(4*j,k) = sigma1(sigmaBeta);
       spotVolData.surface(4*j+1,k) = sigma2(sigmaBeta); 
       spotVolData.surface(4*j+2,k) = sigma3(sigmaBeta);  
       spotVolData.surface(4*j+3,k) = sigmaBeta;  
   end
end

end

