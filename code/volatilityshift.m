function newSpotSurface = volatilityshift(spotSurface, bucketYear)
% 
% shift the volatility surface in the bucket year specified 
% 
% INPUT
% spotSurface = volatility surface to be shifted 
% bucketYear = Bucket to shift the volatility surface on
% 
% OUTPUT
% newSpotSurface = volatility surface shifted on the corresponding bucket

% Definition of the shift:
shift = zeros(39,1);

if bucketYear == 2
    shift(1:7) = 1;
    shift(8:14) = (7:-1:1)/8;
elseif bucketYear == 4
    shift(8:14) = (1:7)/8;
    shift(15) = 1;
    shift(16:26) = (11:-1:1)/12;
elseif bucketYear == 7
    shift(16:26) = (1:11)/12;
    shift(27) = 1;
    shift(28:38) = (11:-1:1)/12;
elseif bucketYear == 10
    shift(28:38) = (1:11)/12;
    shift(39) = 1;
end

newSpotSurface = spotSurface;

for idx = 1:size(shift)
    newSpotSurface.surface(idx,:) = spotSurface.surface(idx,:) + 1e-4*shift(idx);
    newSpotSurface.surface(idx,:) = spotSurface.surface(idx,:) + 1e-4*shift(idx);
end

end

