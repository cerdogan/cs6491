% Get the points
clf
clear all;
%points = inputPoints;
points = [40.0 87.0
131.0 59.0
167.0 70.0
257.0 73.0


];
points = points / 60;
points(:, 2) = 10 - points(:, 2);

% 
p0 = points(1,:);
p1 = points(2,:);
p2 = points(3,:);
p3 = points(4,:);
%p0 = [1.4401    7.2368];
%p1 = [3.1912    6.8275];
%p2 = [4.3664    8.0848];
%p3 = [5.5184    7.2661];
ps = [p0;p1;p2;p3];
plot(ps(:,1), ps(:,2), 'o'); hold on;

% Generate a frame for P0 and P1
v10 = (p1 - p0) / norm(p1 - p0);
v10perp = [-v10(2), v10(1)];
f1p1 = v10 + p0; f1p2 = v10perp + p0;
%plot([p0(1); f1p1(1)], [p0(2); f1p1(2)], 'LineWidth', 2); hold on;
%plot([p0(1); f1p2(1)], [p0(2); f1p2(2)], 'LineWidth', 2); hold on;
plot([p0(1); p1(1)], [p0(2); p1(2)], 'r', 'LineWidth', 2); hold on;
p1b = p0 - v10perp * norm(p1 - p0);
plot([p0(1); p1b(1)], [p0(2); p1b(2)], 'r', 'LineWidth', 2); hold on;
axis square

% Get the projections of P2 and P3 onto the frame defined by P0 and P1
x2 = dot((p2 - p0), v10);
x3 = dot((p3 - p0), v10);
y2 = dot((p2 - p0), v10perp);
y3 = dot((p3 - p0), v10perp);

% Generate a frame for P2 and P3
v32 = (p3 - p2) / norm(p3 - p2);
v32perp = [-v32(2), v32(1)];
f2p1 = v32 + p2; f2p2 = v32perp + p2;
%plot([p2(1); f2p1(1)], [p2(2); f2p1(2)], 'r', 'LineWidth', 2); hold on;
%plot([p2(1); f2p2(1)], [p2(2); f2p2(2)], 'r', 'LineWidth', 2); hold on;
plot([p2(1); p3(1)], [p2(2); p3(2)], 'r', 'LineWidth', 2); hold on;
p3b = p2 - v32perp * norm(p3 - p2);
plot([p2(1); p3b(1)], [p2(2); p3b(2)], 'r', 'LineWidth', 2); hold on;
axis square

% Compute the magnification
m = norm(p2-p3) / norm(p0 - p1);

% Generate N number of frames
pOrigin = p2;
vx = v32;
vy = v32perp;
pA = p2;
pB = p3;
for i = 1 : 6

  % Compute the new coordinates for P4 and P5 in P2P3 frame
  x4 = x2 * m^i;
  y4 = y2 * m^i;
  x5 = x3 * m^i;
  y5 = y3 * m^i;

  % Generate the new points P4 and P5 based on normalized P2P3 frame
  p4 = pOrigin + vx * x4 + vy * y4;
  p5 = pOrigin + vx * x5 + vy * y5;
  plot(p4(1), p4(2), 'o');
  plot(p5(1), p5(2), 'o');

  % Generate a frame for P4 and P5
  v54 = (p5 - p4) / norm(p5 - p4);
  v54perp = [-v54(2), v54(1)];
  f3p1 = v54 + p4; f3p2 = v54perp + p4;
  %plot([p4(1); f3p1(1)], [p4(2); f3p1(2)], 'g', 'LineWidth', 2); hold on;
  %plot([p4(1); f3p2(1)], [p4(2); f3p2(2)], 'g', 'LineWidth', 2); hold on;
  plot([p4(1); p5(1)], [p4(2); p5(2)], 'r', 'LineWidth', 2); hold on;
  p5b = p4 - v54perp * norm(p5 - p4);
  plot([p4(1); p5b(1)], [p4(2); p5b(2)], 'r', 'LineWidth', 2); hold on;
  axis square
  axis([0 10 0 10]);
  grid on;

  % Update the origin and unit vectors
  pOrigin = p4;
  vx = v54;
  vy = v54perp;
  pA = p4;
  pB = p5;
end

p2 = pA;
p3 = pB;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interpolate between the first (p0p1) and the last frame (p2p3)

% Compute m
z = norm(p2-p3) / norm(p0 - p1);

% Compute alpha
v10 = (p1 - p0) / norm(p1 - p0);
v32 = (p3 - p2) / norm(p3 - p2);
a = atan2(dot([-v10(2), v10(1)],v32), dot(v10,v32));

% Compute the center of the log spiral
A = p0; C = p2;
c = cos(a); s = sin(a);
D = (c*z-1)*(c*z-1) + (s*z)*(s*z);
ex = c*z*A(1) - C(1) - s*z*A(2);
ey = c*z*A(2) - C(2) + s*z*A(1);
x=(ex*(c*z-1) + ey*s*z) / D;
y=(ey*(c*z-1) - ex*s*z) / D;
F = [x,y];
plot(F(1), F(2), 'o', 'MarkerSize', 5, 'LineWidth', 2);
  
% Generate the interpolation
FP0 = A - F;
FP1 = p1 - F;
for t = 0 : 0.01 : 1
  alpha = t * a;
  FP0alpha = cos(alpha) * FP0 + sin(alpha) * [-FP0(2), FP0(1)];
  FP1alpha = cos(alpha) * FP1 + sin(alpha) * [-FP1(2), FP1(1)];
  P0 = F + (z^t) * FP0alpha;
  P1 = P0;
  plot([P0(1); P1(1)], [P0(2); P1(2)], 'ro'); hold on;
end















