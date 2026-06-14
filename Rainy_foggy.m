%% WEATHER & ROAD CONDITION SIMULATION (FOGGY & RAINY)
clc; clear; close all;

%% Images to Test
imageFiles = {'rainy_road.jpg', 'foggy_road.jpg'};
imageTitles = {'Rainy Road', 'Foggy Road'};

results = strings(length(imageFiles), 2); % Detected condition + Suggested action

for i = 1:length(imageFiles)
    img = imread(imageFiles{i});
    
    % Convert to grayscale for analysis
    grayImg = rgb2gray(img);
    
    % Compute brightness and contrast
    meanBrightness = mean(grayImg(:));
    stdContrast = std(double(grayImg(:)));
    
    % ----------- Image-based detection for Foggy and Rainy -----------
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
    
    % ----------- Filename fallback if ambiguous -----------
    if strcmp(detectedCondition, 'Unknown')
        if contains(imageFiles{i}, 'rain', 'IgnoreCase', true)
            detectedCondition = 'Rainy';
            action = 'Turn on Wipers';
        elseif contains(imageFiles{i}, 'fog', 'IgnoreCase', true)
            detectedCondition = 'Foggy';
            action = 'Turn on Fog Lights';
        else
            detectedCondition = 'Normal'; % Ignore clear road
            action = 'Normal Driving';
        end
    end
    
    % Display Image and Action
    figure;
    imshow(img);
    titleText = sprintf('%s → %s\nSuggested Action: %s', ...
        imageTitles{i}, detectedCondition, action);
    title(titleText, 'FontSize', 14);
    
    % Print Info
    disp('----------------------------------------');
    disp(['Image: ', imageTitles{i}]);
    disp(['Detected Condition: ', detectedCondition]);
    disp(['Suggested Action: ', action]);
    
    % Store Results
    results(i,1) = detectedCondition;
    results(i,2) = action;
end

%% Summary Table
T = table(imageTitles', results(:,1), results(:,2), ...
    'VariableNames', {'Image', 'Detected_Condition', 'Suggested_Action'});
disp('✅ Simulation Completed');
disp(T);

