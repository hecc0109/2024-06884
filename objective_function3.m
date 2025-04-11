function[ z,cv] =objective_function3( x  )

%% 聚类K_means++
%  K_means140;%用户信息
% K_means100;
K_means180;

global M;
global N;
global user_task;
global rUAV;
global L;
global path0;
global uav_clusters;
global user_pos1;
global C; 


  
for k=1:K
    f(k)=x(k);
end
f=round(f);
for k=1:K
    aerfa(k)=x(k+K);
end
aerfa=round(aerfa,2);


  for m=1:M
       uav_m_clusters =uav_clusters(:,m)'; 
       logicArray =uav_m_clusters > 0;
       selectedElements = uav_m_clusters(logicArray);
       user_pos1_uav{m}= user_pos1(selectedElements);
   end


%% 上传速率


 [Bi,R,Di,Tiup,Tup,Eiup,Eup]=up_rate1(L,C,user_pos1,K,M,aerfa,uav_clusters);   
for m=1:M
    selectedIndices_m =uav_clusters(:,m); 
    nonZeroElements_m = selectedIndices_m(selectedIndices_m~= 0);
    Tiup_m{m} = Tiup(nonZeroElements_m);
    Eiup_m{m} = Eiup(nonZeroElements_m);
end   

%% 计算模型
[Tiloc,Ticom,Tiser,Tfly,Tseri,Tseri_m,Ticom_m,Tiwait_m]=computing_model(Di,Tiup,rUAV,C,K,M,N,uav_clusters,aerfa,f);


Tiege_m = cell(size(Tiup_m));

for i = 1:size(Tiup_m, 1)
    for j = 1:size(Tiup_m, 2)
        assert(numel(Tiup_m{i, j}) == numel(Tiwait_m{i, j}), '子胞体数量不匹配');  
        numCells = numel(Tiup_m{i, j}); 
        Tiege_m{i, j} = cell(size(Tiege_m{i, j}));
        for k = 1:numCells
          Tiege_m{i, j}{k} = Tiup_m{i, j}{k} + Tiwait_m{i, j}{k}+Ticom_m{i, j}{k};

        end
    end
end

%
for m=1:M
    selectedIndices_m =uav_clusters(:,m); 
    nonZeroElements_m = selectedIndices_m(selectedIndices_m~= 0);
    Tiloc_m{m} = Tiloc(nonZeroElements_m);
end


Titotal = cell(size( Tiege_m));

for i = 1:size(Tiege_m, 1)
    for j = 1:size(Tiege_m, 2)
        assert(numel(Tiege_m{i, j}) == numel(Tiloc_m{i, j}), '子胞体数量不匹配');
       SubTitotal = cell(size(Tiege_m{i, j})); 
    
        for k = 1:numel(Tiege_m{i, j}) 
            for c=1:numel(Tiege_m{i, j}{k})
          
            if Tiege_m{i, j}{k}(c,1) >=Tiloc_m{i, j}{k}(c,1)
                SubTitotal{k}(c,1) = Tiege_m{i, j}{k}(c,1);
            else
                SubTitotal{k}(c,1) = Tiloc_m{i, j}{k}(c,1);   
            end
            end
        Titotal{i, j} =SubTitotal;
    end
    end
end

%% 能耗模型
%计算能耗   
[Eiloc,Eicom, Eihover,Efly_m,total_Ecom_m,total_Ehover_m,E]=power_model(Tiloc,Ticom,Tfly,Tiser,K,M,uav_clusters,f);


for m=1:M
    selectedIndices_m =uav_clusters(:,m);
    nonZeroElements_m = selectedIndices_m(selectedIndices_m~= 0);
    Eicom_m{m} = Eicom(nonZeroElements_m); 
    Eihover_m{m} = Eihover(nonZeroElements_m);         
end

%用户节约模型        
[Eisave,Emsave,Eisave_m,Emsave_m, Escom]=saving_model(Di,Eiup,M,K,uav_clusters,aerfa); 

%% 满意度模型

columnsToExtract = [8, 9,10,11];

uCell = cell(size(user_pos1_uav));
for i = 1:numel(user_pos1_uav)
    subCell = user_pos1_uav{i};
    newSubCell = cell(size(subCell));
    for j = 1:numel(subCell)
        subSubCell = subCell{j};
        newSubSubCell = subSubCell(:, columnsToExtract);
        newSubCell{j} = newSubSubCell;
    end
    uCell{i} = newSubCell;  
end

 Ucell = cell(size(uCell));
for i = 1:numel(uCell)
    mergedSubCell = cell(size(uCell{i}));
    for j = 1:numel(uCell{i})
        mergedColumns = [uCell{i}{j}, Titotal{i}{j}, Emsave_m{i}{j}, Eisave_m{i}{j}];
        mergedSubCell{j} = mergedColumns;
    end
     Ucell{i} = mergedSubCell;
end

%计算满意度函数   
[Ui_m,ukm] = satisfaction(Ucell);

num_cells = numel(Ui_m);
ukm = cell(1, num_cells);
sum_ukm=0;
for i = 1:num_cells
    subcell = Ui_m{i};
    num_cells1 = numel(subcell);
  for j=1:num_cells1
    ukm{i}{j}= sum(Ui_m{1, i}{1, j}  ); 
    sum_ukm=sum_ukm+ukm{i}{j};
  end
end
%% 不满意度
dis_ukm=1*user_num-sum_ukm;

% dis_ukm=dis_ukm/user_num;
dis_ukm=dis_ukm/user_num-0.01;%求近似真实帕累托

%% 计算无人机总能耗

num_cells1 = numel(Eicom_m);

E1 = cell(1, num_cells1);
Etotal_com=0;
for i = 1:num_cells1
    subcell1 = Eicom_m{i};
    num_cells1 = numel(subcell1);
  for j=1:num_cells1
    E1{i}{j}= sum(Eicom_m{1, i}{1, j}  ); 
    Etotal_com=Etotal_com+E1{i}{j};
  end
end
%悬停能耗
num_cells2 = numel(Eihover_m);

E2 = cell(1, num_cells2);
Etotal_hover=0;
for i = 1:num_cells2
    subcell2 = Eihover_m{i};
    num_cells2 = numel(subcell2);
  for j=1:num_cells2
    E2{i}{j}= sum(Eihover_m{1, i}{1, j}  ); 
    Etotal_hover=Etotal_hover+E2{i}{j};
  end
end

Etotal_fly=sum(Efly_m);

 Etotal=Etotal_com+Etotal_hover+Etotal_fly;


%% 计算约束违反程度

E=cell2mat(E);


for m=1:M
    g(:,m)=E(:,m);

    if g(:,m) > 60
        violationDegree(:,m) = g(:,m) - 60;

    elseif g(:,m) <0
         violationDegree(:,m) =(0- g(:,m))*100 ;
    else   
        violationDegree(:,m) = 0;  
    end
end

%  %总的不满意度不高于0.4 
%  if dis_ukm > 0.4
%         violationDegree(:,4) = dis_ukm  - 0.4;
% %       violationDegree(:,4) = (dis_ukm  - 0.4)*140;
%     else
%         violationDegree(:,4) = 0;  % 如果满足约束，则违反程度为0
%  end
 if dis_ukm > 0.6
        violationDegree(:,4) = dis_ukm  - 0.6;
    else
        violationDegree(:,4) = 0;  
 end

% %不对满意度约束
% violationDegree(:,4) = 0;


K=12;%24维决策变量
for k=1:K
   a(:,k)= aerfa(:,k);%对卸载率的约束
    if a(:,k)>1
      violationDegree_a(:,k)=a(:,k)-1;
    else
       violationDegree_a(:,k)=0;
    end
    b(:,k)= f(:,k);%对计算速度的约束
      if b(:,k)<100
        violationDegree_f(:,k)=100-b(:,k);
        elseif b(:,k)>200
       violationDegree_f(:,k)=b(:,k)-200;
        else
        violationDegree_f(:,k)=0;
        end
end
% 计算总的约束违反度
   cv = max(0, violationDegree(:,1)) + max(0, violationDegree(:,2))+max(0, violationDegree(:,3))+max(0, violationDegree(:,4))+max(0, violationDegree_a(:,1))+max(0, violationDegree_a(:,2))+max(0, violationDegree_a(:,3))+max(0, violationDegree_a(:,4))+max(0, violationDegree_a(:,5))+max(0, violationDegree_a(:,6))+max(0, violationDegree_a(:,7))+max(0, violationDegree_a(:,8))+max(0, violationDegree_a(:,9))+max(0, violationDegree_a(:,10))+max(0, violationDegree_a(:,11))+max(0, violationDegree_a(:,12)) +max(0, violationDegree_f(:,1))+max(0, violationDegree_f(:,2))+max(0, violationDegree_f(:,3))+max(0, violationDegree_f(:,4))+max(0, violationDegree_f(:,5))+max(0, violationDegree_f(:,6))+max(0, violationDegree_f(:,7))+max(0, violationDegree_f(:,8))+max(0, violationDegree_f(:,9))+max(0, violationDegree_f(:,10))+max(0, violationDegree_f(:,11))+max(0, violationDegree_f(:,12)); %每个个体的违反程度


%% 定义优化目标 满意度最大化 能耗最小化  
 z1=dis_ukm;

 z2=Etotal;
z = [z1 z2]';
end