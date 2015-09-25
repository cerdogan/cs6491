%% @file euler.m
%% @author Can Erdogan
%% @date 2015-09-25
%% @brief Given three angles, respectively around z,y and x
%% returns the rotation matrix.

function R = euler (th1, th2, th3)
  R = rotz(th1 / pi * 180) * roty(th2 / pi * 180) * rotx(th3 / pi * 180);
end
