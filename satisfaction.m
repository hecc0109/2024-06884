%满意度函数

function [Ui_m,ukm] = satisfaction(Ucell)
lata=2;
gamu=0.50;
for i = 1:numel(Ucell)
    for j = 1:numel(Ucell{i})
        Ti_m{i}{j} = [Ucell{i}{j}(:,1)];
        Eir_m{i}{j}=[Ucell{i}{j}(:,2)];
        Eimax_m{i}{j}=[Ucell{i}{j}(:,3)];
        betai_m{i}{j}=[Ucell{i}{j}(:,4)];
        Titotal{i}{j}=[Ucell{i}{j}(:,5)];
        Emasave_m{i}{j}=[Ucell{i}{j}(:,6)];
        Eisave_m{i}{j}=[Ucell{i}{j}(:,7)];
        for c=1:numel(Titotal{i}{j})
            if Ucell{i}{j}(c,5)<=Ucell{i}{j}(c,4)*Ucell{i}{j}(c,1) && Ucell{i}{j}(c,2)>=gamu*Ucell{i}{j}(c,3)
                Ui_m{i}{j}(c,:)=lata-lata^(max(Ucell{i}{j}(c,5)-Ucell{i}{j}(c,1),0)/(Ucell{i}{j}(c,4)*Ucell{i}{j}(c,1)));
            else if Ucell{i}{j}(c,5)<=Ucell{i}{j}(c,4)*Ucell{i}{j}(c,1) && 0<Ucell{i}{j}(c,2) &&Ucell{i}{j}(c,2)<=gamu*Ucell{i}{j}(c,3)
                    Ui_m{i}{j}(c,:)=(lata-lata^(max(Ucell{i}{j}(c,5)-Ucell{i}{j}(c,1),0)/(Ucell{i}{j}(c,4)*Ucell{i}{j}(c,1))))*(lata-lata^((Ucell{i}{j}(c,6)-Ucell{i}{j}(c,7))/Ucell{i}{j}(c,6)));
             else
                    Ui_m{i}{j}(c,:)=0;
                end  
            end
        end
    end
end

%计算每一个区域的满意度
num_cells = numel(Ui_m);

ukm = cell(1, num_cells);
for i = 1:num_cells
subcell = Ui_m{i};
num_cells1 = numel(subcell);
for j=1:num_cells1
ukm{i}{j}= sum(Ui_m{1, i}{1, j}  );
end
end

        
  


