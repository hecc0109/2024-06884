
function referencePoint = DetermineReferencePoint(solutions, offset)
  
 
    maxValues = max(solutions, [], 1);
    
   
    if isscalar(offset)
        offset = repmat(offset, 1, size(solutions, 2));
    end
    
    % 计算参考点
    referencePoint = maxValues + offset;
end