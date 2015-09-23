% Get the points
p0 = [1.4401    7.2368];
p1 = [3.1912    6.8275];
p2 = [4.3664    8.0848];
p3 = [5.5184    7.2661];
ps = [p0;p1;p2;p3];
plot(ps(:,1), ps(:,2), 'o');

% Generate a frame for P0 and P1
v10 = (p1 - p0) / norm(p1 - p0);
v10perp = [-v10(2), v10(1)];
f1p1 = v10 + p0; f1p2 = v10perp + p0;
plot([p0(1); f1p1(1)], [p0(2); f1p1(2)], 'LineWidth', 2); hold on;
plot([p0(1); f1p2(1)], [p0(2); f1p2(2)], 'LineWidth', 2); hold on;
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
plot([p2(1); f2p1(1)], [p2(2); f2p1(2)], 'r', 'LineWidth', 2); hold on;
plot([p2(1); f2p2(1)], [p2(2); f2p2(2)], 'r', 'LineWidth', 2); hold on;
axis square

% Compute the magnification
m = norm(p2-p3) / norm(p0 - p1);

% Compute the new coordinates for P4 and P5 in P2P3 frame
x4 = x2 * m;
y4 = y2 * m;
x5 = x3 * m;
y5 = y3 * m;

% Generate the new points P4 and P5 based on normalized P2P3 frame
p4 = p2 + v32 * x4 + v32perp * y4;
p5 = p2 + v32 * x5 + v32perp * y5;
plot(p4(1), p4(2), 'o');
plot(p5(1), p5(2), 'o');

% Generate a frame for P4 and P5
v54 = (p5 - p4) / norm(p5 - p4);
v54perp = [-v54(2), v54(1)];
f3p1 = v54 + p4; f3p2 = v54perp + p4;
plot([p4(1); f3p1(1)], [p4(2); f3p1(2)], 'g', 'LineWidth', 2); hold on;
plot([p4(1); f3p2(1)], [p4(2); f3p2(2)], 'g', 'LineWidth', 2); hold on;
axis square



