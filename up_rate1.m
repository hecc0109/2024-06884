
function [Bi,R,Di,Tiup, Tup,Eiup,Eup]=up_rate1(L,C,user_pos1,K,M,aerfa,uav_clusters)
   B =2 ;                 

   Pi=0.1;               
    deta2 =1e-17;


    for k=1:K
        Bi{k}=B/C{k};   %区域k中每个用户i分的带宽
        R{k}=Bi{k}*log2(1+Pi/deta2./L{k});  
        Di{k}=user_pos1{k}(:,6);              
    end
    

      for k=1:K
  
               Tiup{k}=aerfa(1,k)*Di{k}./R{k}/5;%每个区域每个用户的数据传输延时

        Eiup{k}=Pi*Tiup{k}; %每个区域每个用户的数据传输能耗      
        Tup{k}=sum(Tiup{k}, 1);    
        Eup{k} = sum(Eiup{k}, 1);

      end

    
