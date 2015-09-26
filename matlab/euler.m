%% @file euler.m
%% @author Can Erdogan
%% @date 2015-09-25
%% @brief Given three angles, respectively around z,y and x
%% returns the rotation matrix.

function R = euler (th1, th2, th3)
  R = rotz(th1 / pi * 180) * roty(th2 / pi * 180) * rotx(th3 / pi * 180);
end

function R = rotx(th)
  c = cos(th); s = sin(th);
  R = [1 0 0; 0 c -s; 0 s c];
end

function R = roty(th)
  c = cos(th); s = sin(th);
  R = [c 0 s; 0 1 0; -s 0 c];
end

function R = rotz(th)
  c = cos(th); s = sin(th);
  R = [c -s 0; s c 0; 0 0 1];
end