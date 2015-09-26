% Record the points
clf
p1 = [1.4766    7.8801];
p2 = [3.1725    8.4649];
d21 = norm(p2 - p1); d43 = norm(p4 - p3);
v21 = (p2 - p1) / d21; v43 = (p4 - p3) / d43;
p2b = p1 + -[-v21(2), v21(1)] * d21;
p3 = [4.0789    7.7632];
p4 = [5.6287    7.4415];
p4b = p3 + -[-v43(2), v43(1)] * d43;
plot([p1(1); p2(1)], [p1(2); p2(2)]); hold on;
plot([p1(1); p2b(1)], [p1(2); p2b(2)]); hold on;
plot([p3(1); p4(1)], [p3(2); p4(2)], 'r'); hold on;
plot([p3(1); p4b(1)], [p3(2); p4b(2)], 'r'); hold on;
axis square;
axis([0 10 0 10]); 

% Generate forward

m = d43 / d21;
