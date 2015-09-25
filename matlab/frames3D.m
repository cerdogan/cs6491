% Generate the triangle 
clear all;
tp0 = [0,0,0.2]';
tp1 = [0.5, 0.0, 0.4]';
tp2 = [0.0, 0.9, 0.0]';

% Generate the input triangles and frames
clf;
o0 = [-0.5,-1,-1]';
R0 = euler(pi/4.5,pi/2,pi/3);
R0 = euler(0,0,0);
t0p0 = o0 + R0 * tp0;
t0p1 = o0 + R0 * tp1;
t0p2 = o0 + R0 * tp2;
t0s = [t0p0'; t0p1'; t0p2'];
fill3(t0s(:,1), t0s(:,2), t0s(:,3), 'r'); hold on;
drawFrame(o0, R0, 'r');

o1 = [1,1.2,1.5]';
o1 = o0;
R1 = euler(pi/3,pi/1.5,8*pi/6);
R1 = euler(0,0,pi/2);
s1 = 0.6;
t1p0 = o1 + s1 * R1 * tp0;
t1p1 = o1 + s1 * R1 * tp1;
t1p2 = o1 + s1 * R1 * tp2;
t1s = [t1p0'; t1p1'; t1p2'];
fill3(t1s(:,1), t1s(:,2), t1s(:,3), 'g'); hold on;

drawFrame(o1, R1, 'k');
axis(2.5 * [-1 1 -1 1 -1 1]);
axis square;
view([-110, 30])
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Given the triangle points, find the magnification m, the normal direction
% of the spiral, N, and the angle alpha

% Compare triangle line segment lengths
m = norm(t1p1 - t1p0) / norm(t0p1 - t0p0);

% The displacement of vertices are perpendicular to the normal
if((norm(t1p0 - t0p0) > 1e-5) && (norm(t1p1 - t0p1) > 1e-5) )
  t10p0 = (t1p0 - t0p0) / norm(t1p0 - t0p0);
  t10p1 = (t1p1 - t0p1) / norm(t1p1 - t0p1);
  N = cross(t10p0, t10p1);
elseif((norm(t1p0 - t0p0) > 1e-5) && (norm(t1p2 - t0p2) > 1e-5) )
  t10p0 = (t1p0 - t0p0) / norm(t1p0 - t0p0);
  t10p2 = (t1p2 - t0p2) / norm(t1p2 - t0p2);
  N = cross(t10p0, t10p2);
elseif((norm(t1p1 - t0p1) > 1e-5) && (norm(t1p2 - t0p2) > 1e-5) )
  t10p1 = (t1p1 - t0p1) / norm(t1p1 - t0p1)
  t10p2 = (t1p2 - t0p2) / norm(t1p2 - t0p2)
  N = cross(t10p1, t10p2);
else assert(false);
end
N = N / norm(N)
plot3([0; N(1)], [0; N(2)], [0; N(3)], 'k-', 'LineWidth', 3);
return;

% Once we know N, we can solve for theta. In general, for some vector v,
% v' = cos(th) v + sin(th) (N x v) + (1 - cos(th)) (N . v) N. If v is
% a vector that represents a triangle segment, then the equation can
% be written as "a cos(th) + b sin(th) = 1" and solved by observing that
% "sqrt(a*a+b*b)sin(th+atan2(b,a)) = 1".
t0v10 = (t0p1 - t0p0) / norm(t0p1 - t0p0);
t1v10 = (t1p1 - t1p0) / norm(t1p1 - t1p0);
NcrossV = cross(N, t0v10);
projV = N * dot(N, t0v10);
syms cth sth;
eq = cth * t0v10(1) + sth * NcrossV(1) + (1 - cth) * projV(1) - t1v10(1);
[C,T] = coeffs(eq, [cth,sth]);
cs = double(C);
if(numel(cs) > 2)
  cs = -cs / cs(3);
  a = cs(1); b = cs(2);
  temp = 1 / sqrt(a*a+b*b);
  alpha = asin(temp) - atan2(b,a);
else
  
  % a cos(th) = 1 case
  if(T(1) == cth)
    alpha = acos(1 / cs(1));
    
  % a sin(th) = 1 case
  elseif(T(1) == sth)
    alpha = asin(1 / cs(1));
  end
end

% Compute the focal point by solving for the first vertex in two triangles
R = vrrotvec2mat([N', alpha]);
A = eye(3) - m * R;
b = (t1p1 - m * R * t0p1);
F = inv(A) * b;
plot3(F(1), F(2), F(3), 'ko', 'MarkerSize', 15, 'LineWidth', 8);
[m * norm(t0p0 - F), norm(t1p0 - F)]
[m * norm(t0p1 - F), norm(t1p1 - F)]
[m * norm(t0p2 - F), norm(t1p2 - F)]



