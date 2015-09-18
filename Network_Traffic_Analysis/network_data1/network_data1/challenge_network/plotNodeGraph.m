function plotNodeGraph(A, xy)
% A is an n-by-n matrix containing the interconnections between nodes, and
% xy is an n-by-2 matrix  

% figure();
hold on;

n = size(A,1);
for ii=1:n
   for jj=1:n
      if (A(ii,jj) > eps)
          % modify the linewidth based on # transmissions.
          lw = floor(log(A(ii,jj))/log(5));
          if (lw < 1)
              lw = 1;
          end
          plot([xy(ii,1) xy(jj,1)], [xy(ii,2) xy(jj,2)], '*-', 'Linewidth', lw);
          plot([xy(ii,1) xy(jj,1)], [xy(ii,2) xy(jj,2)], 'r*', 'Linewidth', lw);
      end
       
   end
    
end