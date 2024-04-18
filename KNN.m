% 指定图像文件夹路径
imageFolderPath = 'C:\Users\SZR\Desktop\2';

% 获取文件夹中的所有图像文件
imageFiles = dir(fullfile(imageFolderPath, '**', '*.bmp'));
numImages = numel(imageFiles);

% 创建存储图像和标签的变量
images = cell(numImages, 1);
labels = zeros(numImages, 1);

% 遍历图像文件，提取图像和标签
for i = 1:numImages
    % 获取图像文件名和标签
    imageFilename = imageFiles(i).name;
    [~, name, ~] = fileparts(imageFilename);
    
    % 提取标签
    underscoreIndex = strfind(name, '_');
    label = str2double(name(1:underscoreIndex-1));
    
    % 读取图像
    image = imread(fullfile(imageFolderPath, imageFilename));
    
    % 存储图像和标签
    images{i} = image;
    labels(i) = label;
end

% 将数据随机划分为训练图像和测试图像
rng(42); % 设置随机数种子，以确保结果可重复
trainRatio = 0.8; % 80% 作为训练图像，20% 作为测试图像
numTrainImages = round(numImages * trainRatio);

trainIndices = randperm(numImages, numTrainImages);
trainImages = images(trainIndices);
trainLabels = labels(trainIndices);

testIndices = setdiff(1:numImages, trainIndices);
testImages = images(testIndices);
testLabels = labels(testIndices);

% 提取训练图像特征
% 这里使用的是图像的像素值作为特征
trainFeatures = cell(numTrainImages, 1);
for i = 1:numTrainImages
    binaryImage = trainImages{i};
    imageFeatures = double(binaryImage(:));  % 将特征转换为数值类型
    trainFeatures{i} = imageFeatures';
end

% 步骤6：将训练特征矩阵转换为训练数据
trainX = cell2mat(trainFeatures);
trainY = trainLabels;


% 步骤7：使用K折交叉验证进行多次迭代
numFolds = 3;  % 设置K折交叉验证的折数
numLabels = 10;  % 标签的数量
accuracyMatrix = zeros(numFolds, numLabels);  % 存储准确率的矩阵

for fold = 1:numFolds
    % 划分训练集和验证集
    cv = cvpartition(numTrainImages, 'KFold', numFolds);
    trainIdx = training(cv, fold);
    validationIdx = test(cv, fold);
    
    trainX_fold = trainX(trainIdx, :);
    trainY_fold = trainY(trainIdx);
    validationX_fold = trainX(validationIdx, :);
    validationY_fold = trainY(validationIdx);
    
    % 训练KNN分类器
    knnModel = fitcknn(trainX_fold, trainY_fold, 'NumNeighbors', 10);
    
    % 使用验证集进行预测
    predictedLabels = predict(knnModel, validationX_fold);
    
    % 计算准确率
    for label = 0:numLabels-1
        idx = validationY_fold == label;
        accuracy = sum(predictedLabels(idx) == validationY_fold(idx)) / sum(idx);
        accuracyMatrix(fold, label+1) = accuracy;
    end
    
    % 输出每次迭代后的准确率矩阵
    disp(['迭代 ', num2str(fold), ' 的准确率矩阵：']);
    disp(accuracyMatrix);
    
    % 计算混淆矩阵
    confusionMatrix = confusionmat(validationY_fold, predictedLabels);
    % 将混淆矩阵中的数量转换为准确率
    confusionMatrix = confusionMatrix ./ sum(confusionMatrix, 2);
    
    % 输出混淆矩阵
    disp(['迭代 ', num2str(fold), ' 的混淆矩阵：']);
    disp(confusionMatrix);
end
% 在训练KNN分类器后，使用以下代码将模型保存为MAT文件
save('trained_knn_model.mat', 'knnModel');

disp('训练好的KNN模型已保存为trained_knn_model.mat文件');
% 获取测试文件夹中的所有图像文件
testFolderPath = imageFolderPath; % 与训练图像文件夹相同
testImageFiles = imageFiles(testIndices);
numTestImages = numel(testImageFiles);

% 随机选择10个测试图像文件
rng(42);  % 设置随机数种子，以确保结果可重复
selectedTestIndices = randperm(numTestImages, 10);

% 创建
% 创建存储测试图像和标签的变量
testImages = cell(10, 1);
testLabels = zeros(10, 1);

% 遍历选定的测试图像文件，提取图像和标签
for i = 1:10
    % 获取测试图像文件名和标签
    testFilename = testImageFiles(selectedTestIndices(i)).name;
    [~, name, ~] = fileparts(testFilename);
    
    % 提取标签
    underscoreIndex = strfind(name, '_');
    label = str2double(name(1:underscoreIndex-1));
    
    % 读取测试图像
    testImage = imread(fullfile(testFolderPath, testFilename));
    
    % 存储测试图像和标签
    testImages{i} = testImage;
    testLabels(i) = label;
end

% 计算选定的测试图片的预测概率
probabilityMatrix = zeros(10, numLabels);  % 存储概率的矩阵

for i = 1:10
    % 读取测试图片
    testImage = testImages{i};
    
    % 提取测试图片特征
    testFeatures = double(testImage(:)');
    
    % 使用训练好的KNN模型计算预测概率
    [~, scores] = predict(knnModel, testFeatures);
    
    % 存储预测概率
    probabilityMatrix(i, :) = scores';
end

% 输出预测概率矩阵
disp('预测概率矩阵：');
disp(probabilityMatrix);

% 将预测概率矩阵写入Excel文件
filename = '预测概率.xlsx';

% 创建表格数据
labels = [0:9]';
data = [labels, probabilityMatrix];

% 使用writematrix函数将数据写入Excel文件
writematrix(data, filename, 'Sheet', 'Predictions', 'Range', 'A1');

disp(['预测概率已写入Excel文件: ', filename]);

