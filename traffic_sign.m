%% Self-Driving Car Vision – Traffic Sign Recognition using CNN
% Course: Neural Networks and Fuzzy Logic (NNFL)
% Topic: Self-Driving Cars using CNN in MATLAB

clc; clear; close all;

% Load pretrained CNN (GoogLeNet)
net = googlenet;
inputSize = net.Layers(1).InputSize;

% Define your image file names and titles
imageFiles = {'sign_sample.jpg', 'sample_image1.jpg', 'sample_image2.jpg'};
imageTitles = {'Traffic Sign 1', 'Traffic Sign 2', 'Traffic Sign 3'};

% Initialize results storage
results = strings(length(imageFiles), 2);  % label + confidence

for i = 1:length(imageFiles)
    % Read and resize each image
    img = imread(imageFiles{i});
    img = imresize(img, inputSize(1:2));

    % Classify image using GoogLeNet
    [label, score] = classify(net, img);
    [sortedScores, idx] = sort(score, 'descend');
    topLabels = net.Layers(end).Classes(idx(1:3));

    % Display image with detected label and confidence
    figure;
    imshow(img);
    title([imageTitles{i}, ' → Detected: ', char(label), ...
        ' (', num2str(max(score)*100, '%.2f'), '% confidence)']);

    % Print results in Command Window
    disp('-------------------------------------------');
    disp(['Results for ', imageTitles{i}, ' (', imageFiles{i}, ')']);
    disp('Top 3 Predictions:');
    for j = 1:3
        fprintf('%d. %s (Confidence: %.2f%%)\n', j, string(topLabels(j)), sortedScores(j)*100);
    end
    disp('-------------------------------------------');

    % Store main result
    results(i,1) = string(label);
    results(i,2) = string(num2str(max(score)*100, '%.2f'));
end

%% Display Final Summary Table
disp(' Classification completed for all images.');
disp(' ');
disp('Final Summary:');
T = table(imageTitles', results(:,1), results(:,2), ...
    'VariableNames', {'Image', 'Detected_Label', 'Confidence(%)'});
disp(T);
