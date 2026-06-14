%% SELF-DRIVING CAR: LANE DETECTION ONLY
clc; clear; close all;

%% Load Video Frame
video = VideoReader('road_sample.mp4');
frame = readFrame(video);
frame = imresize(frame, [480 640]);

%% Convert to grayscale
gray = rgb2gray(frame);

%% ---------------- Lane Detection ----------------
edges = edge(imgaussfilt(gray, 2), 'Canny', [0.1 0.3]);

% Trapezoidal ROI
mask = roipoly(edges, [100 540 640 0], [480 480 320 320]);
roi = edges .* mask;

% Hough Transform
[H, T, R] = hough(roi);
P = houghpeaks(H, 10, 'threshold', ceil(0.2*max(H(:))));
lines = houghlines(roi, T, R, P, 'FillGap', 40, 'MinLength', 40);

left_points = [];
right_points = [];

for k = 1:length(lines)
    pt1 = lines(k).point1;
    pt2 = lines(k).point2;
    dx = pt2(1) - pt1(1);
    dy = pt2(2) - pt1(2);
    slope = dy / (dx + eps);
    if abs(dx) < 20 || abs(slope) < 0.3
        continue
    end
    if slope < 0 && pt1(1) < 320 && pt2(1) < 320
        left_points = [left_points; pt1; pt2];
    elseif slope > 0 && pt1(1) > 320 && pt2(1) > 320
        right_points = [right_points; pt1; pt2];
    end
end

laneImg = frame;

% Draw all lines for debugging (green)
for k = 1:length(lines)
    xy = [lines(k).point1 lines(k).point2];
    laneImg = insertShape(laneImg, 'Line', xy(:)', 'Color', 'green', 'LineWidth', 2);
end

% Draw averaged left lane (yellow)
if ~isempty(left_points)
    p_left = polyfit(left_points(:,1), left_points(:,2), 1);
    y1 = 480; y2 = 320;
    x1 = (y1 - p_left(2)) / p_left(1);
    x2 = (y2 - p_left(2)) / p_left(1);
    laneImg = insertShape(laneImg, 'Line', [x1 y1 x2 y2], 'Color', 'yellow', 'LineWidth', 5);
end

% Draw averaged right lane (yellow)
if ~isempty(right_points)
    p_right = polyfit(right_points(:,1), right_points(:,2), 1);
    y1 = 480; y2 = 320;
    x1 = (y1 - p_right(2)) / p_right(1);
    x2 = (y2 - p_right(2)) / p_right(1);
    laneImg = insertShape(laneImg, 'Line', [x1 y1 x2 y2], 'Color', 'yellow', 'LineWidth', 5);
end

%% Display Final Result
imshow(laneImg);
title('Lane Detection (Yellow)');
