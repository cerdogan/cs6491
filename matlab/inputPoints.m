%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% @file inputPoints.m
%% @author Can Erdogan
%% @date Nov 10, 2012
%% @brief Reads inputs from the mouse 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function points = inputPoints ()
  points = [];
  axis([0 10 0 10]); hold on;
  axis square
  grid on;
  for i = 1 : 10000
    [x,y,m] = ginput(1);
    if(m == 3), break; end;
    points(end+1, :) = [x,y];
    plot(x,y, 'o'); hold on;
  end;
end