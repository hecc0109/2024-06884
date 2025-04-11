clc;
clear;
close all;

%%%%%%%罚函数
global penalty_factor;
  penalty_factor = 1e4;
rateOfIncrease=0.3;


%%%%%%%%%ε约束
 global epsilon;
 epsilon=5;
rateOfDecrease=0.1;%惩罚因子随着迭代减小

global M;
global N;
global user_task;
global rUAV;
global L;
global path0;
global uav_clusters;
global user_pos1;
global C;


%% 聚类K_means++
%   K_means140;
% K_means100;%用户信息 
K_means180;%用户信息 

 %% 设置无人机的初始坐标
  M=2;
% M = 3;   %3架无人机  
%  M = 4; 

N=ceil(K/M);  
hUAV = 50;                                          % 飞行高度
rI =  repmat([0, 0, 50], M, 1);                     %  (M*3) 3维 初始位置
rF =  repmat([500, 500, 50], M, 1);               %  终点位置 
%% 通信模型 平均路径损耗
cluster_features_new = sortrows(cluster_features_new, 4);%按照区域优先级排序好的特征集 数字越小 优先级越高

rUAV=cluster_features_new(:,1:2);
rUAV(:,3)=50; %无人机固定的飞行高度
user_task = randi([30, 50], user_num, 1); 

% %180用户
user_task =[44;35;48;41;39;41;46;49;36;49;32;40;31;41;33;46;39;34;37;49;43;31;50;42;38;31;45;34;50;34;43;31;38;50;36;42;31;50;36;47;43;44;49;44;39;41;33;50;37;38;48;44;34;46;42;36;46;44;44;44;35;40;39;46;30;32;31;49;42;46;48;35;40;37;42;40;48;34;34;42;37;50;34;31;36;43;38;38;43;46;50;43;49;46;33;30;47;42;34;37;32;30;31;31;34;45;50;46;30;49;49;30;46;31;40;48;34;46;36;48;40;44;48;43;32;49;35;39;36;43;38;32;50;49;35;41;48;48;30;34;33;43;47;48;46;38;34;35;33;44;47;44;32;46;35;50;42;38;47;40;50;43;39;39;36;34;48;43;40;37;45;37;32;40;30;32;31;33;44;50];
user_pos(:,6)=user_task ;

% % 140用户
% user_task =[50;34;36;36;40;47;37;36;49;36;36;42;42;33;36;47;32;44;42;35;49;31;37;33;34;49;41;36;41;31;45;44;38;48;33;46;36;38;31;42;30;49;48;49;49;44;32;44;42;48;35;45;46;38;47;50;44;40;33;37;47;36;39;39;39;35;41;44;47;31;37;38;45;48;35;36;44;44;42;31;38;45;50;50;38;41;36;39;42;48;46;50;48;47;40;43;39;40;38;44;35;44;39;43;48;35;35;34;34;41;40;47;33;35;31;48;48;39;43;37;42;35;30;31;37;34;41;45;49;35;33;36;39;42;50;41;40;38;35;50];
% user_pos(:,6)=user_task ;

% %100用户
% user_task =[36;47;47;48;37;46;46;35;46;44;32;30;40;45;50;47;41;36;44;42;31;50;34;37;36;34;36;33;36;43;32;39;46;47;34;48;41;32;46;32;32;36;49;45;43;50;36;35;34;40;49;30;33;44;39;45;48;50;41;40;36;39;41;40;32;30;30;41;43;46;39;37;47;36;37;47;50;46;44;38;34;45;47;38;42;37;40;45;35;50;36;38;49;46;49;37;41;35;44;30];
% user_pos(:,6)=user_task ;

for k=1:K
    index_pos=(user_pos(:,5)==k);
    user_pos1{k}=user_pos(index_pos,:) ;
    C{k}=size(user_pos1{k},1);   
end
%  计算无人机在每个区域与所在区域用户的路径损耗
[ L] = pathloss1(rUAV, user_pos1,K,C);

cluster_features_new= [cluster_features_new,(1:num_clusters)'];
%% 无人机调度

%对M个无人机分别设置起点和终点
rUAV = zeros(N+2, 3, M);    
for m = 1:M
    rUAV(1, :, m) = rI(m, :); 
    rUAV(N+2, :, m) = rF(m, :); 
end
%无人机在每个簇质点坐标悬停
path(:,1:2) = cluster_features_new(:,1:2); 
path(:,3)=0; 

 path0=path;

% % % %%%%%%%%%%四个无人机路径180用户
% path0= [155.468071736183,47.7322589304011,0;269.987920139144,457.000691402169,0;433.356954855713,282.886262110041,0;350.932755952437,382.086932927949,0;
% 341.878403003079,82.5034542444968,0;160.659742087854,439.225479671299,0;257.171077100227,241.855653606553,0;462.651800879413,430.372584547995,0;
% 463.446772461031,81.2607501357325,0;40.6470243269895,410.676170031600,0;82.9054852387589,143.762736246176,0;139.222257652565,308.024107171235,0];

% 
%    %%%%%%%%三个无人机路径 180用户
% path0=[155.468071736183,47.7322589304011,0;269.987920139144,457.000691402169,0;433.356954855713,282.886262110041,0;
%     341.878403003079,82.5034542444968,0;160.659742087854,439.225479671299,0;350.932755952437,382.086932927949,0;
%     257.171077100227,241.855653606553,0;139.222257652565,308.024107171235,0;462.651800879413,430.372584547995,0;
%     82.9054852387589,143.762736246176,0;40.6470243269895,410.676170031600,0;463.446772461031,81.2607501357325,0];


% % %%%%%%两个无人机路径180用户
path0=[155.468071736183,47.7322589304011,0;269.987920139144,457.000691402169,0;
433.356954855713,282.886262110041,0;350.932755952437,382.086932927949,0;
341.878403003079,82.5034542444968,0;160.659742087854,439.225479671299,0;
257.171077100227,241.855653606553,0;462.651800879413,430.372584547995,0;
82.9054852387589,143.762736246176,0;139.222257652565,308.024107171235,0;
463.446772461031,81.2607501357325,0;40.6470243269895,410.676170031600,0];

% %%%%%%%%%三个无人机路径140用户
%      path0=[77.4444444444444,25.7777777777778,0;253.428571428571,419.071428571429,0;448.666666666667,448.916666666667,0;
%             257.700000000000,71.3000000000000,0;30.5000000000000,297.666666666667,0;125.533333333333,261.733333333333,0;
%             413.062500000000,198.437500000000,0;65,431.400000000000,0;252.538461538462,260.384615384615,0;
%             412.714285714286,58.7142857142857,0;73.8571428571429,118.714285714286,0;385.357142857143,363.285714285714,0];  


% % %%%%%%%%%四个无人机路径140用户
%     path0=[77.4444444444444,25.7777777777778,0;253.428571428571,419.071428571429,0;448.666666666667,448.916666666667,0;257.700000000000,71.3000000000000,0;
%            257.700000000000,71.3000000000000,0;65,431.400000000000,0;413.062500000000,198.437500000000,0;30.5000000000000,297.666666666667,0;
%             412.714285714286,58.7142857142857,0;252.538461538462,260.384615384615,0;385.357142857143,363.285714285714,0;73.8571428571429,118.714285714286,0];

% %         
% % %   %%%%%%%%两个无人机路径140用户
%    path0=[77.4444444444444,25.7777777777778,0;253.428571428571,419.071428571429,0;
%           125.533333333333,261.733333333333,0;448.666666666667,448.916666666667,0;
%            30.5000000000000,297.666666666667,0;257.700000000000,71.3000000000000,0;
%            65,431.400000000000,0;413.062500000000,198.437500000000,0;
%            252.538461538462,260.384615384615,0; 385.357142857143,363.285714285714,0;
%            73.8571428571429,118.714285714286,0;412.714285714286,58.7142857142857,0];  

%   %%%%%%%%两个无人机路径100用户
%    path0=[190.500000000000,79.2500000000000,0;362.444444444444,275.888888888889,0;
%             288.166666666667,315.833333333333,0;475.300000000000,331.100000000000,0;
%            52.5000000000000,375.200000000000,0;57.8750000000000,172,0;
%            350.375000000000,463,0;447.333333333333,237.444444444444,0
%            159.222222222222,305,0;263.333333333333,214.111111111111,0;
%             46.8571428571429,17.8571428571429,0;375.181818181818,63.6363636363636,0];

%%%%%%%%三个无人机路径 100用户
% path0=[190.500000000000,79.2500000000000,0;362.444444444444,275.888888888889,0;475.300000000000,331.100000000000,0;
% 57.8750000000000,172,0;288.166666666667,315.833333333333,0;52.5000000000000,375.200000000000,0;
% 159.222222222222,305,0;447.333333333333,237.444444444444,0;350.375000000000,463,0;
% 46.8571428571429,17.8571428571429,0;375.181818181818,63.6363636363636,0;263.333333333333,214.111111111111,0];

% %%%%%%%%%%四个无人机路径 100用户
% path0=[190.500000000000,79.2500000000000,0;362.444444444444,275.888888888889,0;475.300000000000,331.100000000000,0;288.166666666667,315.833333333333,0;
%          57.8750000000000,172,0;447.333333333333,237.444444444444,0;350.375000000000,463,0;52.5000000000000,375.200000000000,0;
%        46.8571428571429,17.8571428571429,0;375.181818181818,63.6363636363636,0;263.333333333333,214.111111111111,0;159.222222222222,305,0];


% % %%%%%%%针对4无人机140用户
% path0=[97.5625000000000,52.3750000000000,0;41.9000000000000,400.200000000000,0;339.272727272727,36,0;455.857142857143,80.2857142857143,0;
%      276.700000000000,164.600000000000,0;160.333333333333,425.111111111111,0;435.625000000000,436.062500000000,0;424.666666666667,294.666666666667,0;
%      199.363636363636,259.363636363636,0;77.1428571428571,245.928571428571,0;302.058823529412,383.235294117647,0;419.100000000000,181.400000000000,0];

for n = 2:N+1 
    for m = 1:M
        for i=1:K
          if path0(i,3) == 0 
             rUAV(n, :, m) = [path0(i,1:2),50]; 
             path0(i,3) =1;      
            break
          end
        end
    end
end


uav_clusters=[];
for m=1:M
uav_row= []; 
    for n=2:N+1
        [~, rowIndex] = ismember(rUAV(n, 1:2, m),center_coord_1(:,1:2), 'rows');
        row=find(user_pos(:,5)==rowIndex);  
        user_pos(row,7)=m;               
        uav_row = [uav_row ; rowIndex];
    end
    
      uav_clusters= [uav_clusters,uav_row ];
end

%% 把每个无人机服务的区域提取出来

 user_pos(:,8)=Ti;   %用户第8列  理想可容忍延迟
 user_pos(:,9)=Eir;  %第9列 剩余能量 
 user_pos(:,10)=Eimax;% 第10列 用户最大能量
 user_pos(:,11)=betai;%第11列
   for k=1:K
       index_pos=(user_pos(:,5)==k);
       user_pos1{k}=user_pos(index_pos,:) ;
   end
   

   for m=1:M
       row1= find(user_pos(:,7)==m);
       uav_user{m}=user_pos(row1,:);
   end
   

   for m=1:M
       uav_m_clusters =uav_clusters(:,m)';
       logicArray =uav_m_clusters > 0;
       selectedElements = uav_m_clusters(logicArray);
       user_pos1_uav{m}= user_pos1(selectedElements);
   end
   

%% Problem Definition   

 CostFunction = @(x)objective_function( x  );
nVar = 24;             
VarSize = [1 nVar];   
VarMin =[50,50,50,50,50,50,50,50,50,50,50,50,0,0,0,0,0,0,0,0,0,0,0,0];
VarMax =[300,300,300,300,300,300,300,300,300,300,300,300,2,2,2,2,2,2,2,2,2,2,2,2]; 

% Number of Objective Functions
nObj = numel(CostFunction(unifrnd(VarMin, VarMax, VarSize)));

%% NSGA-II Parameters
MaxIt =500;      % Maximum Number of Iterations
nPop =100;        % Population Size
mu = 0.02;         
sigma =[10,10,10,10,10,10,10,10,10,10,10,10,0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.05];
pc1=0.9;
pc2=0.9;
pm1=0.1;
pm2=0.1;

%% Initialization
empty_individual.Position = [];
empty_individual.Cost = [];
empty_individual.Rank = [];
empty_individual.DominationSet = [];
empty_individual.DominatedCount = [];
empty_individual.CrowdingDistance = [];
pop = repmat(empty_individual, nPop, 1);

for i = 1:nPop
   

minValue1 = 100;  
maxValue1 = 150;   
numPoints = 12; 
randomPoints = zeros(1, numPoints); 
for i1 = 1:numPoints
    randomValue1 = rand();  
    randomPoint1 = minValue1 + (maxValue1 - minValue1) * randomValue1;  
    randomPoints11(1,i1) = randomPoint1; 
end
 
minValue2 = 0.5;  
maxValue2 = 0.8;   
numPoints = 12; 
randomPoints = zeros(1, numPoints);  
for i2 = 1:numPoints
    randomValue2 = rand(); 
    randomPoint2 = minValue2 + (maxValue2 - minValue2) * randomValue2; 
    randomPoints22(1,i2) = randomPoint2;
end

    pop(i).Position=[randomPoints11,randomPoints22];
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
    pop(i).Cost = CostFunction(pop(i).Position);
    
    [z,cv] =objective_function(pop(i).Position  );
    pop(i).cv = cv;%每个个体的违反程度

end

% Non-Dominated Sorting
[pop, F] = NonDominatedSorting(pop);

% Calculate Crowding Distance 
pop = CalcCrowdingDistance(pop, F);

% Sort Population 
[pop, F] = SortPopulation(pop);


%% NSGA-II Main Loop
    popm = repmat(empty_individual, nPop, 1);
          popc = repmat(empty_individual, nPop/2, 1);  
           popm1 = repmat(empty_individual, nPop/2, 1);
            popm2 = repmat(empty_individual, nPop/2, 1);
            
%加入RL 选择那些个体进行交叉 那些个体进行变异
 Q = zeros(5, 2); % Assuming two actions: 1 for crossover, 2 for mutation
epsilon1 = 0.1; % Exploration rate
alpha = 0.1; % Learning rate
% gamma = 0.9; % Discount factor
gamma = 0.8;
Q=[1,0;0,1;1,0;0,1;1,0];
for it = 1:MaxIt
   
%计算归一化后倒数的适应度
z= [pop.Cost]';
z1=z(:,1);%不满意度
z2=z(:,2);%无人机总能耗
% 最小-最大归一化
X1min = min(z1);
X1max = max(z1);
X1norm = (z1 - X1min) / (X1max - X1min);

X1norm = X1norm+0.1 ;
Z1 =1 ./ X1norm;
Z1avg=mean(Z1);
Z1max=max(Z1);

X2min = min(z2);
X2max = max(z2(:));
X2norm = (z2 - X2min) / (X2max - X2min);
X2norm = X2norm+0.1 ;
Z2=1 ./ X2norm;    
Z2avg=mean(Z2(:) );
Z2max=max(Z2);

%两个适应度归一化倒数和
Z=Z1+Z2;
Zavg=Z1avg+Z2avg;

% %%衰减学习率
% alpha=1/(1+it);
% %%衰减探索率
% epsilon1=1/(1+it/10);

  for i = 1:5
  if rand < epsilon1
       
        action = randi([1, 2]);
    else
        
        [~, action] = max(Q(i, :));
     end
    
    if action == 1
        % Crossover action
        cv=0;
        for ii=1:10
        i1 = 10*(i-1)+ii;
        p1 = pop(i1);
        i2 = 10*(10-i)+ii;
        p2 = pop(i2);
            Zbig=max(Z(i1), Z(i2));
          if Zbig>=Zavg
              Pc=pc1*(max(Z)-Zbig)/(max(Z)-Zavg);
          else
              Pc=pc2;
          end
        
        [popc(i1, 1).Position, popc(i1, 2).Position] = CrossoverII(p1.Position, p2.Position,Pc);
        popc(i1, 1).Cost = CostFunction(popc(i1, 1).Position);
        popc(i1, 2).Cost = CostFunction(popc(i1, 2).Position);
        
        [z1,cv1] =objective_function(popc(i1,1).Position  );
        [z2,cv2] =objective_function(popc(i1,2).Position  );
        popc(i1,1).cv = cv1;
        popc(i1,2).cv = cv2;
        cv=cv+cv1+cv2;
        end
       
        % Update Q-table for crossover action
        reward = -cv; 
        Q(i, action) = Q(i, action) + alpha * (reward + gamma * max(Q(i, :)) - Q(i, action));
    elseif action == 2
         cv=0;
        for ii=1:10
       
            
    % Mutation action
        idx1 = 10*(i-1)+ii;
        p1 = pop(idx1);
        
        if Z(ii)>=Zavg 
              Pm=pm1*(max(Z)-Z(ii))/(max(Z)-Zavg);
          else
              Pm=pm2;
        end
          
        popm1(idx1).Position = Mutate(p1.Position, sigma,Pm);
        popm1(idx1).Cost = CostFunction(popm1(idx1).Position);
        
        [z,cv1] = objective_function(popm1(idx1).Position);
        popm1(idx1).cv = cv1;
        
        idx2 = 10*(10-i)+ii;
        p2 = pop(idx2);
        
        popm2(idx2).Position = Mutate(p2.Position, sigma,Pm);
        popm2(idx2).Cost = CostFunction(popm2(idx2).Position);
        
        [z,cv2] = objective_function(popm2(idx2).Position);
        popm2(idx2).cv = cv2;
        cv=cv+cv1+cv2;
        end
        
        
        % Update Q-table for mutation action
         reward = -cv; % Assuming the reward is the negative of constraint violation
        Q(i, action) = Q(i, action) + alpha * (reward + gamma * max(Q(i, :)) - Q(i, action));
    end   
end
popc = popc(:);



for i = numel(popc):-1:1
    if isempty(popc(i).Position)
        popc(i) = [];
    end
end
for i = numel(popm1):-1:1
    if isempty(popm1(i).Position)
        popm1(i) = [];
    end
end

for i = numel(popm2):-1:1
    if isempty(popm2(i).Position)
        popm2(i) = [];
    end
end

% Merge
    pop = [pop
        popc
        popm1
        popm2];
    
   % Non-Dominated Sorting
    [pop, F] = NonDominatedSorting(pop);

    % Calculate Crowding Distance
    pop = CalcCrowdingDistance(pop, F);

    % Sort Population
    pop = SortPopulation(pop); 
    
    % Truncate
    pop = pop(1:nPop);  
  
    % Non-Dominated Sorting
    [pop, F] = NonDominatedSorting(pop);

    % Calculate Crowding Distance
    pop = CalcCrowdingDistance(pop, F);

    % Sort Population
    [pop, F] = SortPopulation(pop);

 
z= [pop.Cost]';
z1=z(:,1);
z2=z(:,2);

X1min = min(z1);
X1max = max(z1);
X1norm = (z1 - X1min) / (X1max - X1min);

X1norm = X1norm+0.1 ;
Z1 =1 ./ X1norm;
Z1avg=mean(Z1 );
Z1max=max(Z1);

X2min = min(z2);
X2max = max(z2(:));
X2norm = (z2 - X2min) / (X2max - X2min);
X2norm = X2norm+0.1 ;
Z2=1 ./ X2norm;    
Z2avg=mean(Z2(:) );
Z2max=max(Z2);


Z=Z1+Z2;
Zavg=Z1avg+Z2avg;

   popc = repmat(empty_individual, nPop/2, 2); 
      for k = 1:nPop/2

        i1 = randi([1 nPop]);
        p1 = pop(i1);
        
        i2 = randi([1 nPop]);
        p2 = pop(i2);
          
           Zbig=max(Z(i1), Z(i2));
          if Zbig>=Zavg
              Pc=pc1*(max(Z)-Zbig)/(max(Z)-Zavg);
          else
              Pc=pc2;
          end
          
        [popc(k, 1).Position, popc(k, 2).Position] = CrossoverII(p1.Position, p2.Position,Pc);
          
        CostFunction = @(x)objective_function( x  );
        popc(k, 1).Cost = CostFunction(popc(k, 1).Position);
        popc(k, 2).Cost = CostFunction(popc(k, 2).Position);
        
        [z1,cv1] =objective_function(popc(k,1).Position  );
        [z2,cv2] =objective_function(popc(k,2).Position  );
        popc(k,1).cv = cv1;
        popc(k,2).cv = cv2;
        
    end
    popc = popc(:);
    

    popm = repmat(empty_individual,nPop/2, 1);
    for k = 1:nPop/2
 i = randi([1 nPop]);
        p = pop(i);
       
          if Z(k)>=Zavg 
              Pm=pm1*(max(Z)-Z(k))/(max(Z)-Zavg);
          else
              Pm=pm2;
          end
        
        popm(k).Position = Mutate(p.Position, sigma,Pm);
        popm(k).Cost = CostFunction(popm(k).Position);
        
        
        [z,cv] =objective_function(popm(k).Position  );
        popm(k).cv = cv;
           
        
    end
    
    % Merge
    pop = [pop
         popc
         popm]; 
     
    % Non-Dominated Sorting
    [pop, F] = NonDominatedSorting(pop);

    % Calculate Crowding Distance
    pop = CalcCrowdingDistance(pop, F);

    % Sort Population
    pop = SortPopulation(pop); 
    

    Score=zeros(length(pop),3);
     
    for yueshu=1:3

      if yueshu==1 %执行罚函数约束
        
          global penalty_factor;  
           penalty_factor = penalty_factor * (1+ rateOfIncrease);
          
           for k = 1:length(pop)
              CostFunction1 = @(x)objective_function1( x  );
              pop1(k, 1).Cost = CostFunction1(pop(k, 1).Position);
             
             [z11,cv11] =objective_function1(pop(k,1).Position  );
             pop1(k,1).cv = cv11;
             %%%%%%个体顺序
             pop1(k,1).sx = k;
           end
           
    % Non-Dominated Sorting
    [pop1, F] = NonDominatedSorting(pop1);
    % Calculate Crowding Distance
    pop1 = CalcCrowdingDistance(pop1, F);
    % Sort Population
    pop1 = SortPopulation(pop1); 
 
    %计算得分
    for k = 1:length(pop1)
        Score(pop1(k, 1).sx,1)= k;  
    end
    
     elseif yueshu==2   %%%%ε约束方法
         global epsilon;  
         epsilon = epsilon * (1-rateOfDecrease);
           for k = 1:length(pop)
              CostFunction2 = @(x)objective_function2( x  );
              pop2(k, 1).Cost = CostFunction2(pop(k, 1).Position);        
            
             [z22,cv22] =objective_function2(pop(k,1).Position  );
             pop2(k,1).cv = cv22;     
          
             pop2(k,1).sx = k;
           end
            
    % Non-Dominated Sorting
    [pop2, F] = NonDominatedSorting(pop2);
    % Calculate Crowding Distance
    pop2 = CalcCrowdingDistance(pop2, F);
    % Sort Population
    pop2 = SortPopulation(pop2); 

    %计算得分
    for k = 1:length(pop2)
        Score(pop2(k, 1).sx,2)= k;  
    end
    
        %%%%%%第三种约束CDP
      else
          for k = 1:length(pop)
              CostFunction3 = @(x)objective_function3( x  );
              pop3(k, 1).Cost = CostFunction3(pop(k, 1).Position);  
           
             [z33,cv33] =objective_function3(pop(k,1).Position  );
             pop3(k,1).cv = cv33;
             %%%%%%个体顺序
             pop3(k,1).sx = k;
          end   
          
    % Non-Dominated Sorting
    [pop3, F] = CDP_NonDominatedSorting(pop3);
    % Calculate Crowding Distance
    pop3 = CalcCrowdingDistance(pop3, F);
    % Sort Population
    pop3 = SortPopulation(pop3); 

  
    %计算得分
    for k = 1:length(pop3)
        Score(pop3(k, 1).sx,3)= k;  
    end
    
      end
    end
    %计算总得分
          for k = 1:length(pop)
        Total_Score(k,1)=k;
         Total_Score(k,2)=Score(k,1)+Score(k,2)+Score(k,3);
          end
      %选取前N个进入下一代
          
[~, idx] = sort( Total_Score(:, 2)); % 获取索引
sorted_matrix = Total_Score(idx, :); % 按索引重排行

  for k = 1:100
    New_pop(k)=pop(sorted_matrix(k,1));
  end
  
   pop= New_pop;

  % Non-Dominated Sorting
    [pop, F] = NonDominatedSorting(pop);

    % Calculate Crowding Distance
    pop = CalcCrowdingDistance(pop, F);

    % Sort Population
    pop = SortPopulation(pop); %比如100个体 按照顺序排好

    pop=pop';
    

    % Store F1
    F1 = pop(F{1});
    
    % Show Iteration Information
    disp(['Iteration ' num2str(it) ': Number of F1 Members = ' num2str(numel(F1))]);
    
    % Plot F1 Costs
    figure(1);
    PlotCosts(F1);
    pause(0.01);
    
  %%计算IGD  
    ReferencePoints  =load('2UAV180-2.mat');

%     fieldData = ReferencePoints.ReferencePoints;
  fieldData = ReferencePoints.paretoFront;
    ReferencePoints = double(fieldData);
   
    paretoFront = [F1.Cost]'; 
  
    %%%%计算IGD值
    IGD(it ,1)=it ;
    IGD(it ,2) = calculateIGD(paretoFront, ReferencePoints);
    
    %%%%计算HV
    offset=0.1;
    solutions=[F1.Cost]';  
    referencePoint1 = DetermineReferencePoint(ReferencePoints, offset);
    HV(it ,1)=it ;
    HV (it ,2)= calculateHV(solutions, referencePoint1);
  
 end




%% 可视化聚类和计算量分类结果

idx=user_pos(:,5);       
zero_matrix= zeros(num_clusters,1);
C_coord=[center_coord,zero_matrix];

figure(3);
scatter3(user_pos(:,1), user_pos(:,2),user_pos(:,3),10, idx, 'filled');
hold on;
plot3(C_coord(:,1), C_coord(:,2),C_coord(:,3),'kx', 'MarkerSize', 15, 'LineWidth', 3);
hold on
plot3(rUAV(:,1,1),rUAV(:,2,1),rUAV(:,3,1),'b.-','LineWidth',2,'MarkerSize',10);
hold on
plot3(rUAV(:, 1, 2), rUAV(:, 2, 2), rUAV(:, 3, 2),'r.-','LineWidth',2,'MarkerSize',10);
% hold on
% plot3(rUAV(:, 1, 3), rUAV(:, 2, 3), rUAV(:, 3, 3),'g.-','LineWidth',2,'MarkerSize',10);
% % 
% hold on
% plot3(rUAV(:, 1, 4), rUAV(:, 2, 4), rUAV(:, 3, 4),'y.-','LineWidth',2,'MarkerSize',10);



% title(sprintf('K-means clustering with k=%d', K));
% xlim([0, ground_size(1)]);
% ylim([0, ground_size(2)]);
% zlim([0, ground_height]);
% xlabel('X position');      
% ylabel('Y position');
% zlabel('Z position');

% %% 画IGD迭代图
% figure(4);
% % 提取x和y坐标
% x_coordinates = IGD(:, 1);
% y_coordinates = IGD(:, 2);
% % 使用plot函数绘制折线图
% plot(x_coordinates, y_coordinates, '-o'); 
% % 添加标题和标签
% title('采用NSGAII的IGD值');
% xlabel('迭代次数');
% ylabel('IGD');
% %% 画HV迭代图
% figure(5);
% % 提取x和y坐标
% x_coordinates = HV(:, 1);
% y_coordinates = HV(:, 2);
% % 使用plot函数绘制折线图
% plot(x_coordinates, y_coordinates, '-o'); 
% % 添加标题和标签
% title('采用NSGAII的HV值');
% xlabel('迭代次数');
% ylabel('HV');
