    
function [ L] = pathloss1(rUAV, user_pos1,K,C)
    fc = 2e3;                                   % 载波频率
    c = 3e8;                                    % 光速(m/sec)
    alpha = 2;                                  % 路径损耗指数
    % 以下系数基于环境城市模型
    a = 11.95;
    b = 0.14;

    etaLoS = 10^(1/10);
    etaNLoS = 10^(20/10);


for k=1:K 
    for i=1:C{k}
    % UAV and user Los 距离 
    d{k}(i) = sqrt((rUAV(k,1)-user_pos1{k}(i,1))^2+(rUAV(k,2)-user_pos1{k}(i,2))^2+(rUAV(k,3)-user_pos1{k}(i,3))^2);%无人机高度50m 用户0m
    % 无人机与用户之间的仰角
    theta{k}(i)= 180/pi*asin(abs(rUAV(k,3)-user_pos1{k}(i,3))/d{k}(i));
    % 计算 LoS and NLoS 概率
    pLoS{k}(i) = 1/(1+a*exp(-b*(theta{k}(i)-a)));
    pNLoS{k}(i) = 1-pLoS{k}(i);
    % 平均路径损耗
    L{k}(i,:) =pLoS{k}(i)*etaLoS*(4*pi*fc*d{k}(i)/c)^alpha+pNLoS{k}(i)*etaNLoS*(4*pi*fc*d{k}(i)/c)^alpha;
    end
end
  