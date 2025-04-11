

function y = Mutate(x, sigma,Pm)


   nVar = numel(x);
   nMu = ceil(Pm*nVar);
    j = randsample(nVar, nMu);
    if numel(sigma)>1  
        sigma = sigma(j);
    end 
    y = x;
    
   
    delta = sigma .* randn(size(j));
       
    for i = 1:length(j)
        index = j(i);
        y(index) = x(index) + delta(i);
    end


end
