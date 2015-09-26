% Generate the triangle 
clear all;
tp0 = [0,0,0.2]';
tp1 = [0.5, 0.0, 0.4]';
tp2 = [0.0, 0.9, 0.0]';

% Generate the input triangles and frames
clf;
set(gcf,'Renderer','OpenGL');
o0 = [-0.5,-1,-1]';
R0 = euler(pi/4.5,pi/2,pi/3);
%R0 = euler(0,0,0);
t0p0 = o0 + R0 * tp0;
t0p1 = o0 + R0 * tp1;
t0p2 = o0 + R0 * tp2;
t0s = [t0p0'; t0p1'; t0p2'];
fill3(t0s(:,1), t0s(:,2), t0s(:,3), 'r'); hold on;
drawFrame(o0, R0, 'r');
f0p0 = o0 + R0(:,1);
f0p1 = o0 + R0(:,2);
f0p2 = o0 + R0(:,3);

o1 = [1,1.2,1.5]';
%o1 = o0 + [1.5,1.5,0]';
R1 = euler(pi/3,pi/1.5,8*pi/6);
%R1 = euler(1.5,0,0);
s1 = 0.6;
t1p0 = o1 + s1 * R1 * tp0;
t1p1 = o1 + s1 * R1 * tp1;
t1p2 = o1 + s1 * R1 * tp2;
t1s = [t1p0'; t1p1'; t1p2'];
fill3(t1s(:,1), t1s(:,2), t1s(:,3), 'g'); hold on;
f1p0 = o1 + R1(:,1);
f1p1 = o1 + R1(:,2);
f1p2 = o1 + R1(:,3);

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

% The displacement of (unscaled) vertices are perpendicular to the normal
% Instead of vertices, use the unit vectors
if((norm(f1p0 - f0p0) > 1e-5) && (norm(f1p1 - f0p1) > 1e-5) )
  f10p0 = (f1p0 - f0p0) / norm(f1p0 - f0p0);
  f10p1 = (f1p1 - f0p1) / norm(f1p1 - f0p1);
  N = cross(f10p0, f10p1);
elseif((norm(f1p0 - f0p0) > 1e-5) && (norm(f1p2 - f0p2) > 1e-5) )
  f10p0 = (f1p0 - f0p0) / norm(f1p0 - f0p0);
  f10p2 = (f1p2 - f0p2) / norm(f1p2 - f0p2);
  N = cross(f10p0, f10p2);
elseif((norm(f1p1 - f0p1) > 1e-5) && (norm(f1p2 - f0p2) > 1e-5) )
  f10p1 = (f1p1 - f0p1) / norm(f1p1 - f0p1);
  f10p2 = (f1p2 - f0p2) / norm(f1p2 - f0p2);
  N = cross(f10p1, f10p2);
else assert(false);
end
N = N / norm(N)
plot3([0; N(1)], [0; N(2)], [0; N(3)], 'k-', 'LineWidth', 3);

% Once we know N, we can solve for theta. In general, for some vector v,
% v' = cos(th) v + sin(th) (N x v) + (1 - cos(th)) (N . v) N. If v is
% a vector that represents a triangle segment, then the equation can
% be written as "a cos(th) + b sin(th) = 1" and solved by observing that
% "sqrt(a*a+b*b)sin(th+atan2(b,a)) = 1".
%t0v10 = (t0p1 - t0p0) / norm(t0p1 - t0p0);
%t1v10 = (t1p1 - t1p0) / norm(t1p1 - t1p0);
t0v10 = (t0p1 - t0p0) / norm(t0p1 - t0p0);
t1v10 = (t1p1 - t1p0) / norm(t1p1 - t1p0);
[t0v10', t1v10']
NcrossV = cross(N, t0v10);
projV = N * dot(N, t0v10);
syms cth sth;
eq = cth * t0v10(1) + sth * NcrossV(1) + (1 - cth) * projV(1) - t1v10(1);
if(simplify(eq) == 0)
    'case 2'
    eq = cth * t0v10(2) + sth * NcrossV(2) + (1 - cth) * projV(2) - t1v10(2);
    if(simplify(eq) == 0)
        'case 3'
        eq = cth * t0v10(3) + sth * NcrossV(3) + (1 - cth) * projV(3) - t1v10(3);
        if(simplify(eq) == 0), assert(false); end;
    end
end
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
    cs = -cs / cs(2);
    alpha = acos(1 / cs(1));
    
  % a sin(th) = 1 case
  elseif(T(1) == sth)
    cs = -cs / cs(2);
    alpha = asin(1 / cs(1));
  end
end
alpha

N = -N;

% Compute the focal point by solving for the first vertex in two triangles
R = vrrotvec2mat([N', alpha]);
A = eye(3) - m * R;
b = (t1p1 - m * R * t0p1);
f = inv(A) * b;

plot3(f(1), f(2), f(3), 'ko', 'MarkerSize', 10, 'LineWidth', 5);
%[m * norm(t0p0 - F), norm(t1p0 - F)]
%[m * norm(t0p1 - F), norm(t1p1 - F)]
%[m * norm(t0p2 - F), norm(t1p2 - F)]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interpolate between the two frames

for t = 0 : 0.1 : 1
  
  % Rotate the offset FP0 by angle alpha around N using the equation
  % v' = cos(th) v + sin(th) (N x v) + (1 - cos(th)) (N . v) N
  ps = [t0p0, t0p1, t0p2];
  newPs = zeros(3);
  for i = 1 : 3
    p0 = ps(:,i);
    fp0 = p0 - f;
    th = t * alpha;
    cth = cos(th); sth = sin(th);
    fpt2 = cth * fp0 + sth * cross(N, fp0) + (1 - cth) * (dot(N,fp0) * N);
    fpt = m^t * fpt2;
    pt = f + fpt;
    newPs(i,:) = pt;
  end
  %newPs
  plot3(newPs(1,1), newPs(1,2), newPs(1,3), 'ro'); hold on;
  plot3(newPs(2,1), newPs(2,2), newPs(2,3), 'go'); hold on;
  plot3(newPs(3,1), newPs(3,2), newPs(3,3), 'o'); hold on;
  fill3(newPs(:,1), newPs(:,2), newPs(:,3), [1-t,t,0], 'FaceAlpha', 0.5); hold on;

  
  
end

