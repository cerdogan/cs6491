% Generate the triangle 
clear all;
tp0 = [0,0,0.2]';
tp1 = [0.5, 0.0, 0.4]';
tp2 = [0.0, 0.9, 0.0]';

% Generate the input triangles and frames
clf;
set(gcf,'Renderer','OpenGL');
o0 = [-0.5,-1,-1]';
%R0 = euler(pi/4.5,pi/2,pi/3);
R0 = euler(0,0,0);
t0p0 = o0 + R0 * tp0;
t0p1 = o0 + R0 * tp1;
t0p2 = o0 + R0 * tp2;
t0s = [t0p0'; t0p1'; t0p2'];
fill3(t0s(:,1), t0s(:,2), t0s(:,3), 'r'); hold on;
%drawFrame(o0, R0, 'r');

%o1 = [1,1.2,1.5]';
%on = 4 * (rand(3,1) - 0.5);
%on = o0 + [0.5,0.5,0]';
on = o0 + 1 * (rand(3,1) - 0.5)
%R1 = euler(pi/3,pi/1.5,8*pi/6);
%randAngles = 2 * pi * (rand(3,1) - 0.5);
randAngles = 0.5 * (rand(3,1) - 0.5);
Rn = euler(randAngles(1), randAngles(2), randAngles(3));
%Rn = euler(0.2,0,0);
sn = 0.9; %max(rand, 0.3);
tnp0 = on + sn * Rn * tp0;
tnp1 = on + sn * Rn * tp1;
tnp2 = on + sn * Rn * tp2;
tns = [tnp0'; tnp1'; tnp2'];
fill3(tns(:,1), tns(:,2), tns(:,3), 'c'); hold on;

%drawFrame(on, Rn, 'k');
axis(2.5 * [-1 1 -1 1 -1 1]);
axis square;
view([-110, 30])
%view([-180, 90])
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interpolate between the first frame (R0,o0) and the next one (Rn, on)
% to get a final frame (R1,o1)

% Get the projections of the next triangle onto the normalized vectors of 
% the first triangle
w0x = (t0p1 - t0p0) / norm(t0p1 - t0p0);
w0z = cross(w0x, (t0p2 - t0p0) / norm(t0p2 - t0p0));
w0z = w0z / norm(w0z);
w0y = cross(w0z, w0x);
w0y = w0y / norm(w0y);
proj0x = dot((tnp0 - t0p0), w0x);
proj0y = dot((tnp0 - t0p0), w0y);
proj0z = dot((tnp0 - t0p0), w0z);
proj1x = dot((tnp1 - t0p0), w0x);
proj1y = dot((tnp1 - t0p0), w0y);
proj1z = dot((tnp1 - t0p0), w0z);
proj2x = dot((tnp2 - t0p0), w0x);
proj2y = dot((tnp2 - t0p0), w0y);
proj2z = dot((tnp2 - t0p0), w0z);

op = tnp0;
wpx = (tnp1 - tnp0) / norm(tnp1 - tnp0);
wpz = cross(wpx, (tnp2 - tnp0) / norm(tnp2 - tnp0));
wpz = wpz / norm(wpz);
wpy = cross(wpz, wpx);
wpy = wpy / norm(wpy);
for i = 1 : 4
  
  % Generate the new triangle points 
  tnp0 = op + sn^i * (proj0x * wpx + proj0y * wpy + proj0z * wpz); 
  tnp1 = op + sn^i * (proj1x * wpx + proj1y * wpy + proj1z * wpz); 
  tnp2 = op + sn^i * (proj2x * wpx + proj2y * wpy + proj2z * wpz); 

  % Visualize the triangle
  tns = [tnp0'; tnp1'; tnp2'];
  fill3(tns(:,1), tns(:,2), tns(:,3), 'b'); hold on;

  % Set the next "previous" frame information
  op = tnp0;
  wpx = (tnp1 - tnp0) / norm(tnp1 - tnp0);
  wpz = cross(wpx, (tnp2 - tnp0) / norm(tnp2 - tnp0));
  wpz = wpz / norm(wpz);
  wpy = cross(wpz, wpx);
  wpy = wpy / norm(wpy);
  
end

t1p0 = tnp0;
t1p1 = tnp1;
t1p2 = tnp2;
t1s = [t1p0'; t1p1'; t1p2'];
fill3(t1s(:,1), t1s(:,2), t1s(:,3), 'g'); hold on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Given the triangle points, find the magnification m, the normal direction
% of the spiral, N, and the angle alpha

% Compare triangle line segment lengths
m = norm(t1p1 - t1p0) / norm(t0p1 - t0p0);

% Define three normalized edge vector for each triangle
w0v10 = (t0p1 - t0p0) / norm(t0p1 - t0p0);
w0v20 = (t0p2 - t0p0) / norm(t0p2 - t0p0);
w0v21 = (t0p2 - t0p1) / norm(t0p2 - t0p1);
w1v10 = (t1p1 - t1p0) / norm(t1p1 - t1p0);
w1v20 = (t1p2 - t1p0) / norm(t1p2 - t1p0);
w1v21 = (t1p2 - t1p1) / norm(t1p2 - t1p1);

% The displacement of (unscaled) vertices are perpendicular to the normal
% Instead of vertices, use the unit vectors
N1 = cross((w1v10 - w0v10), (w1v20 - w0v20));
N2 = cross((w1v10 - w0v10), (w1v21 - w0v21));
N3 = cross((w1v20 - w0v20), (w1v21 - w0v21));
N1 = N1 / norm(N1);
N2 = N2 / norm(N2);
N3 = N3 / norm(N3);
N = (N1 + N2 + N3) / 3;

% Project the normalized edge vectors onto the plane that contains the
% origin and perpendicular to N and find the angle between them.
w0v10p = w0v10 - dot(N, w0v10) * N;
w0v10pn = w0v10p / norm(w0v10p);
w1v10p = w1v10 - dot(N, w1v10) * N;
w1v10pn = w1v10p / norm(w1v10p);
sin(dot(w0v10pn, w1v10pn))
alpha = atan2(norm(cross(w0v10pn, w1v10pn)), dot(w0v10pn, w1v10pn));
if(dot(cross(w0v10pn, w1v10pn), N) < 0)
  alpha = -alpha;
end;

% Compute the focal point by solving for the first vertex in two triangles
R = vrrotvec2mat([N', alpha]);
A = eye(3) - m * R;
b = (t1p1 - m * R * t0p1);
f = inv(A) * b;
fN = f + N;
%plot3([f(1); fN(1)], [f(2); fN(2)], [f(3); fN(3)], 'k-', 'LineWidth', 3);
%plot3(f(1), f(2), f(3), 'ko', 'MarkerSize', 10, 'LineWidth', 5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interpolate between the two frames

for t = 0 : 0.03 : 1
  
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
  %plot3(newPs(1,1), newPs(1,2), newPs(1,3), 'ro'); hold on;
  %plot3(newPs(2,1), newPs(2,2), newPs(2,3), 'go'); hold on;
  %plot3(newPs(3,1), newPs(3,2), newPs(3,3), 'o'); hold on;
  h = fill3(newPs(:,1), newPs(:,2), newPs(:,3), [1-t,t,0], 'FaceAlpha', 0.7); hold on;
  pause(0.03);
  delete(h);
end

