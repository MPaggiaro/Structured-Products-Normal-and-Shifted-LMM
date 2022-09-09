function s = swaprate(discounts, delta)
% 
% INPUT
% compute the par swap rate 
% discounts = discount curve used for pricing 
% delta = time intervals between the fixed payments
% 
% OUTPUT
% s = the par swap rate

    s = (1 - discounts(end))/dot(discounts,delta);
end
