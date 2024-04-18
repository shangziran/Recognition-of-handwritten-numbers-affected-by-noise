% 加载训练好的KNN模型
load('trained_knn_model.mat');

% 提示用户选择一张手写数字的图片
[imageFilename, imageFolderPath] = uigetfile('*.bmp', 'Select the hand-written digit image');

% 读取选择的图片
testImage = imread(fullfile(imageFolderPath, imageFilename));

% 显示所选图片
figure;
imshow(testImage);
title('手写数字图片');

% 将图像转为灰度图像（如果是彩色图像的话）
if size(testImage, 3) > 1
    grayImage = rgb2gray(testImage);
else
    grayImage = testImage;
end

% 高斯滤波
filteredImage = imgaussfilt(grayImage, 1); % 这里的1是高斯滤波的标准差，可以根据需要调整

% 二值化处理
threshold = graythresh(filteredImage); % 使用Otsu阈值确定二值化阈值
binaryImage = imbinarize(filteredImage, threshold);
% 去除小的像素聚类
    binaryImage = bwareaopen(binaryImage, 5);

% 显示处理后的二值化图片
figure;
imshow(binaryImage);
title('处理后的二值化图片');


% 提取测试图片特征
testFeatures = double(binaryImage(:)');

% 使用加载的KNN模型进行预测
[predictedLabel, ~] = predict(knnModel, testFeatures);

% 显示预测结果
disp(['预测结果：', num2str(predictedLabel)]);
