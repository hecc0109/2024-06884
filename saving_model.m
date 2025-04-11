
 function[ Eisave,Emsave,Eisave_m,Emsave_m, Escom]=saving_model(Di,Eiup,M,K,uav_clusters,aerfa)
 ki= 10^-5;        


fi=40;
funit=1000;           
Picom=ki*(fi)^3;  

      for k=1:K

            Escom{k}=Picom*funit*aerfa(1,k)*Di{k}/fi/100;     %每个区域每个用户的本地计算能耗
            
                   Emscom{k}=Picom*funit*Di{k}/fi/100;          
      end

    
 for k=1:K
  Eisave{k}=Escom{k}-Eiup{k};
  Emsave{k}=Emscom{k}-Eiup{k};
 end
 
for m=1:M
    selectedIndices_m =uav_clusters(:,m); 
    nonZeroElements_m = selectedIndices_m(selectedIndices_m~= 0);
    Eisave_m{m} = Eisave(nonZeroElements_m);
    Emsave_m{m} = Emsave(nonZeroElements_m);
end