

function b = CDP_Dominates(x, y,P,P1)




        cv1 = P;
        cv2 = P1;
    
    if cv1 == 0 && cv2 == 0
       
         if isstruct(x)
             x = x.Cost;
         end
         if isstruct(y)
             y = y.Cost;
         end
         b = all(x <= y) && any(x<y);
         
     elseif cv1 < cv2

        b = 1;
        
    
          
       else

      b = 0;
    end
      
    


end