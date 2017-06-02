% GOF - goodness of fit. 
%       Calculate the coefficient of determination between
%       data and a fit
%
%       INPUT    data - the fitted data
%                fit  - the corresponding descrete fit data
%
%       OUTPUT   Rsqrd    - the coefficient of determination
%
%JLM 11/15/02   
%
function [Rsqrd] = GOF(data,fit)
 
if size(data) ~= size(fit)
fit = fit';
end

SSE = sum((data-fit).^2); %calculate the error sum of squares
SSTO = sum( (data - mean(data)).^2); %calculate the total sum of squares
Rsqrd = (SSTO-SSE)/SSTO;


