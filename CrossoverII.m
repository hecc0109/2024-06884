

function [y1, y2] = CrossoverII(x1, x2,Pc)



        y2 =Pc .*x1+(1-Pc).*x2; 
        y1 =Pc.*x2+(1-Pc).*x1;


     nVar = numel(x1); 
     nC = ceil(Pc*nVar);   
     y2 =[x1(:,1:nC),x2(:,nC+1:end)]; 
     y1 =[x2(:,1:nC),x1(:,nC+1:end)]; 
        
    
end

