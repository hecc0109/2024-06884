%%计算模型
function[Tiloc,Ticom,Tiser,Tfly,Tseri,Tseri_m,Ticom_m,Tiwait_m]=computing_model(Di,Tiup,rUAV,C,K,M,N,uav_clusters,aerfa,f)


funit=1000;            


 fi=40;

V=60;    %无人机飞行速度


      for k=1:K

    Tiloc{k}=funit*(1-aerfa(1,k))*Di{k}/fi/1000;                      
    Tloc{k}=sum(Tiloc{k},1);             
    Ticom{k}=funit*aerfa(1,k)*Di{k}/f(1,k)/1000;     
    Tcom{k}=sum(Ticom{k},1);     %每个区域的计算时延
    Tiser{k}=Tiup{k}+Ticom{k};       %每个区域每个用户的数据传输延时+边缘计算延时   
    Tser{k}=sum(Tiser{k},1);         %每个区域的数据传输延时+边缘计算延时

      end

  

%等待延时  组间延时+组内延时+飞行  Tseri每个区域每个用户的等待延迟
for k= 1:K
    for  i=2:C{k}
         Tseri{k}(1)=0;
         Tseri{k}(i,1)=Tiser{k}(i-1,1)+Tseri{k}(i-1,1);       
    end
end

for m=1:M
    selectedIndices_m =uav_clusters(:,m); 
    nonZeroElements_m = selectedIndices_m(selectedIndices_m~= 0);
    Tseri_m{m} = Tseri(nonZeroElements_m);
    Ticom_m{m} = Ticom(nonZeroElements_m);
end
%计算无人机m在两个区域之间的飞行时间
for m=1:M
    for n=1:N+1
     Tfly(m,n)=norm (rUAV(n+1, 1:2, m) -rUAV(n, 1:2, m))/V; 
    end
end

%除第一个区域之外的等待延迟  还要加上更高优先级组的延迟时间
  for m=1:M  
 
       Tseri1_m{1,m}{1,1}=Tseri_m{1,m}{1,1}+Tfly(m,1);

       

    if N== numel( Tseri_m{1,m})
        for n=2:N
            Tseri1_m{1,m}{1,n}=Tseri_m{1,m}{1,n}+Tseri1_m{1,m} {1,n-1}(end,1)+Tfly(m,n);    

        end
    else
        for n=2:N-1
            Tseri1_m{1,m}{1,n}=Tseri_m{1,m}{1,n}+Tseri1_m{1,m} {1,n-1}(end,1)+Tfly(m,n);    

        end
    end
  end
    Tiwait_m= Tseri1_m;       %等待延迟
    
  
