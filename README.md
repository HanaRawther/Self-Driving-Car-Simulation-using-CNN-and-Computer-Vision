Overview

This project is a MATLAB-based autonomous driving simulation that integrates deep learning and computer vision techniques to model 
perception and decision-making in self-driving cars. The system focuses on traffic sign recognition, lane detection, weather classification, and speed control.

Features
Traffic sign recognition using GoogLeNet CNN with transfer learning
Lane detection using classical computer vision techniques
Weather condition classification module
Speed control logic based on road and environment conditions
Integration of deep learning and traditional vision methods
Autonomous driving behavior simulation in MATLAB environment
Methodology

The system combines convolutional neural networks with classical image processing techniques. A pretrained GoogLeNet model is 
fine-tuned using transfer learning for traffic sign classification. Computer vision algorithms are used for lane detection and environmental analysis.
The outputs from all modules are integrated to simulate autonomous vehicle decision-making.

Modules
Perception Module: Traffic sign recognition using CNN
Lane Detection Module: Edge detection and image processing techniques
Environment Module: Weather classification using visual features
Control Module: Speed adjustment and decision-making logic
Dataset

Traffic sign images and road scene data were used for training and testing the CNN model. (Specify dataset source here if applicable, 
such as GTSRB or custom dataset.)

Tools and Technologies
MATLAB
Deep Learning Toolbox
Computer Vision Toolbox
GoogLeNet (Transfer Learning)
Convolutional Neural Networks (CNN)
Results

The system successfully demonstrates simulated autonomous driving behavior by integrating perception outputs with control logic. 
The CNN model achieves effective traffic sign classification, while vision-based modules handle lane and environment detection.

How to Run
Open the MATLAB project folder
Load the main script file
Run the simulation script
View outputs for detection and control modules
