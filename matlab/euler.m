%% @file euler.m
%% @author Can Erdogan
%% @date 2015-09-25
%% @brief Given three angles, respectively around z,y and x
%% returns the rotation matrix.

function R = euler (th1, th2, th3)
  R = rotz_2(th1) * roty_2(th2) * rotx_2(th3);
end

function R = rotx_2(th)
  c = cos(th); s = sin(th);
  R = [1 0 0; 0 c -s; 0 s c];
end

function R = roty_2(th)
  c = cos(th); s = sin(th);
  R = [c 0 s; 0 1 0; -s 0 c];
end

function R = rotz_2(th)
  c = cos(th); s = sin(th);
  R = [c -s 0; s c 0; 0 0 1];
end