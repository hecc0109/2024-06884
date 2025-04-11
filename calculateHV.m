
function HV = calculateHV(solutions, referencePoint1)
    
    solutions = sortrows(solutions, 1);
    
    % 初始化超体积值
    HV = 0;
    

    for i = 1:size(solutions, 1)
        if i < size(solutions, 1)
          
            width = solutions(i+1, 1) - solutions(i, 1);

        else
          
            width= referencePoint1(1) - solutions(i, 1);
        end
        
       
        height = referencePoint1(2) - solutions(i, 2);
        
        
        HV = HV + width * height;
    end
    
    
    return


    
    
end