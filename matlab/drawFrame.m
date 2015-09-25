%% @file drawFrame.m
%% @author Can Erdogan
%% @date 2015-09-25
%% @brief Draws a frame in 3D for a given rotation matrix R
%% and origin o.

function [] = drawFrame (o, R, c)

  scale = 1.0;
  w = 3;
  v1 = scale * R(:,1) / norm(R(:,1));
  v2 = scale * R(:,2) / norm(R(:,2));
  v3 = scale * R(:,3) / norm(R(:,3));
  p0 = o;
  p1 = o + v1;
  p2 = o + v2;
  p3 = o + v3;
  plot3([p0(1); p1(1)], [p0(2); p1(2)], [p0(3); p1(3)], 'r', 'LineWidth', w); hold on;
  plot3([p0(1); p2(1)], [p0(2); p2(2)], [p0(3); p2(3)], 'g', 'LineWidth', w); hold on;
  plot3([p0(1); p3(1)], [p0(2); p3(2)], [p0(3); p3(3)], 'b', 'LineWidth', w); hold on;
 % plot3(p0(1), p0(2), p0(3), ['o', c], 'LineWidth', w+3, 'MarkerSize', 7); hold on;
end