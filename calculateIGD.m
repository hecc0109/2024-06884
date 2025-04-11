function IGD = calculateIGD(paretoFront, ReferencePoints)


    
n_ref=size(ReferencePoints,1);
for i=1:n_ref
    ref_m=repmat(ReferencePoints(i,:),size(paretoFront,1),1); 
    d=paretoFront-ref_m;    
    D=sum(abs(d).^2,2).^0.5;         
    obtained_to_ref(i)=min(D);
end
IGD=sum(obtained_to_ref)/n_ref;
end


