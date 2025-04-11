
function [Eiloc,Eicom, Eihover,Efly_m,total_Ecom_m,total_Ehover_m,E, Eitotal]=power_model(Tiloc,Ticom,Tfly,Tiser,K,M,uav_clusters,f)
ki= 10^-5;        %Capacitance coefficient 

 Pfly=0.5;     
 fi=40;
funit=1000;           
Sm=10^-5;           %无人机m的电容系数
  
Phover=0.4;

Picom=ki*(fi)^3;   


      for k=1:K

       Pmcom{k}=Sm*(f(1,k))^3;   

      end


for k=1:K
     Eiloc{k}=Picom*Tiloc{k};       %本地计算能耗
     Eicom{k}=Pmcom{k}*Ticom{k}/10;
     Ecom{k} = sum(Eicom{k}, 1);    %无人机m在区域k中完成所有用户任务的总计算能耗
     Eihover{k}=Phover*Tiser{k}/10;
     Ehover{k}=sum(Eihover{k}, 1);    %无人机服务每个区域的悬停能耗
end

for m=1:M
    total_Ecom_m{m} = 0;
    total_Ehover_m{m}=0;
    selectedIndices_m =uav_clusters(:,m); 
    nonZeroElements_m = selectedIndices_m(selectedIndices_m~= 0);
    Eicom_m{m} = Eicom(nonZeroElements_m);  
    Ecom_m{m} = Ecom(nonZeroElements_m);
    Eihover_m{m} = Eihover(nonZeroElements_m);
    Ehover_m{m} = Ehover(nonZeroElements_m);
    for i = 1:numel(Ecom_m{m})
        total_Ecom_m{m} = total_Ecom_m{m}  + Ecom_m{m}{i};%每个无人机消耗的总的计算能耗
        total_Ehover_m{m} =total_Ehover_m{m}  +Ehover_m{m}{i};     %每个无人机消耗的总的悬停能耗
    end
end


Efly=Tfly*Pfly;
for m=1:M
Efly_m=sum(Efly,2);
end

%总能耗    每个无人机 计算能耗+飞行能耗+悬停能耗
for m=1:M
    E{m}=total_Ecom_m{m}+total_Ehover_m{m}+Efly_m(m,1);
end

