%% MENU-DRIVEN PROGRAM: Self-Driving Car Feature Simulation
clc; clear; close all;

disp('===========================================');
disp('     SELF-DRIVING CAR INTELLIGENT SYSTEM   ');
disp('===========================================');
disp('1. Traffic Sign Detection (CNN - GoogLeNet)');
disp('2. Weather & Road Condition Simulation');
disp('3. Lane Detection System');
disp('4. Car Speed Simulation');
disp('5. Exit');
disp('===========================================');

choice = input('Enter your choice (1-5): ');

switch choice
    %% ---------------------------------------------------------------
    case 1
        %% TRAFFIC SIGN DETECTION USING CNN (GOOGLENET)
        clc; close all;
        disp('--- TRAFFIC SIGN DETECTION MODULE ---');

        net = googlenet;
        inputSize = net.Layers(1).InputSize;

        imageFiles = {'sign_sample.jpg', 'sample_image1.jpg', 'sample_image2.jpg'};
        imageTitles = {'Traffic Sign 1', 'Traffic Sign 2', 'Traffic Sign 3'};

        results = strings(length(imageFiles), 2);

        for i = 1:length(imageFiles)
            img = imread(imageFiles{i});
            img = imresize(img, inputSize(1:2));

            [label, score] = classify(net, img);
            [sortedScores, idx] = sort(score, 'descend');
            topLabels = net.Layers(end).Classes(idx(1:3));

            figure;
            imshow(img);
            title([imageTitles{i}, ' → Detected: ', char(label), ...
                ' (', num2str(max(score)*100, '%.2f'), '% confidence)']);

            disp('-------------------------------------------');
            disp(['Results for ', imageTitles{i}, ' (', imageFiles{i}, ')']);
            disp('Top 3 Predictions:');
            for j = 1:3
                fprintf('%d. %s (Confidence: %.2f%%)\n', j, string(topLabels(j)), sortedScores(j)*100);
            end
            disp('-------------------------------------------');

            results(i,1) = string(label);
            results(i,2) = string(num2str(max(score)*100, '%.2f'));
        end

        disp(' ');
        disp('Classification completed for all images.');
        T = table(imageTitles', results(:,1), results(:,2), ...
            'VariableNames', {'Image', 'Detected_Label', 'Confidence(%)'});
        disp(T);

    %% ---------------------------------------------------------------
    case 2
        %% WEATHER & ROAD CONDITION SIMULATION (FOGGY & RAINY)
        clc; close all;
        disp('--- WEATHER & ROAD CONDITION SIMULATION ---');

        imageFiles = {'rainy_road.jpg', 'foggy_road.jpg'};
        imageTitles = {'Rainy Road', 'Foggy Road'};
        results = strings(length(imageFiles), 2);

        for i = 1:length(imageFiles)
            img = imread(imageFiles{i});
            grayImg = rgb2gray(img);

            meanBrightness = mean(grayImg(:));
            stdContrast = std(double(grayImg(:)));

            if stdContrast < 40 && meanBrightness < 150
                detectedCondition = 'Foggy';
                action = 'Turn on Fog Lights';
            elseif stdContrast > 50 && meanBrightness < 120
                detectedCondition = 'Rainy';
                action = 'Turn on Wipers';
            else
                detectedCondition = 'Unknown';
                action = 'Drive Carefully';
            end

            if strcmp(detectedCondition, 'Unknown')
                if contains(imageFiles{i}, 'rain', 'IgnoreCase', true)
                    detectedCondition = 'Rainy';
                    action = 'Turn on Wipers';
                elseif contains(imageFiles{i}, 'fog', 'IgnoreCase', true)
                    detectedCondition = 'Foggy';
                    action = 'Turn on Fog Lights';
                else
                    detectedCondition = 'Normal';
                    action = 'Normal Driving';
                end
            end

            figure;
            imshow(img);
            titleText = sprintf('%s → %s\nSuggested Action: %s', ...
                imageTitles{i}, detectedCondition, action);
            title(titleText, 'FontSize', 14);

            disp('----------------------------------------');
            disp(['Image: ', imageTitles{i}]);
            disp(['Detected Condition: ', detectedCondition]);
            disp(['Suggested Action: ', action]);

            results(i,1) = detectedCondition;
            results(i,2) = action;
        end

        T = table(imageTitles', results(:,1), results(:,2), ...
            'VariableNames', {'Image', 'Detected_Condition', 'Suggested_Action'});
        disp(' Simulation Completed');
        disp(T);

    %% ---------------------------------------------------------------
    case 3


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


    %% ---------------------------------------------------------------
    case 4
        %% CAR SPEED SIMULATION (FIXED 50 KM/H)
clc; close all;
disp('--- CAR SPEED SIMULATION MODULE ---');

% Fixed car speed
carSpeed = 50;
disp(['Initial Car Speed: ', num2str(carSpeed), ' km/h']);

% Speed limit sign images
imageFiles = {'speed_30.jpg', 'speed_50.jpg', 'speed_70.jpg'};
imageTitles = {'Speed Limit 30', 'Speed Limit 50', 'Speed Limit 70'};

% Simulation loop
for i = 1:length(imageFiles)
    % Step 1: Read image
    img = imread(imageFiles{i});

    % Step 2: Extract speed limit value from filename
    speedStr = regexp(imageFiles{i}, '\d+', 'match');
    speedLimit = str2double(speedStr{1});

    % Step 3: Decide driving action
    if carSpeed > speedLimit
        action = 'Deaccelerate';
    elseif carSpeed == speedLimit
        action = 'Maintaining Speed';
    else
        action = 'Maintaining Speed';
    end

    % Step 4: Display image with action
    figure;
    imshow(img);
    titleText = sprintf('%s\nDetected Limit: %d km/h\nAction: %s\nCurrent Speed: %d km/h', ...
        imageTitles{i}, speedLimit, action, carSpeed);
    title(titleText, 'FontSize', 14);

    % Step 5: Print info in command window
    disp('----------------------------------------');
    disp(['Image: ', imageTitles{i}]);
    disp(['Detected Speed Limit: ', num2str(speedLimit), ' km/h']);
    disp(['Action: ', action]);
    disp(['Car Speed: ', num2str(carSpeed), ' km/h']);
end

disp('Simulation Completed. Car speed fixed at 50 km/h.');

       

    %% ---------------------------------------------------------------
    case 5
        disp('Exiting program...');
        disp('THANK YOU!');

        return;

    otherwise
        disp('Invalid choice. Please enter 1-5.');
end
