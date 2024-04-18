clear all;
close all;

% 选择输入和输出文件夹路径
inputFolder = uigetdir('Select the input folder');
outputFolder = uigetdir('Select the output folder');

% 获取输入文件夹中的所有 BMP 文件
fileList = dir(fullfile(inputFolder, '*.bmp'));

% 扩展原图像的高斯滤波，对应文档的方案2
sigma = 1;      % sigma赋值
N = 1;            % 大小是（2N+1）×（2N+1）
N_row = 2*N+1;

gausFilter = fspecial('gaussian',[N_row N_row],sigma); % MATLAB 自带高斯模板滤波

for i = 1:numel(fileList)
    % 读取原始图像
    filename = fileList(i).name;
    originimg = imread(fullfile(inputFolder, filename));
    originimg = im2gray(originimg);
    [ori_row, ori_col] = size(originimg);

    % 应用高斯滤波
    blur = imfilter(originimg, gausFilter, 'conv');

    % 求高斯模板H
    H = zeros(N_row, N_row);
    for ai = 1:N_row
        for aj = 1:N_row
            fenzi = double((ai - N - 1)^2 + (aj - N - 1)^2);
            H(ai, aj) = exp(-fenzi / (2 * sigma * sigma)) / (2 * pi * sigma);
        end
    end
    H = H / sum(H(:)); % 归一化

    desimg = zeros(ori_row, ori_col); % 滤波后图像
    midimg = zeros(ori_row + 2 * N, ori_col + 2 * N); % 中间图像
    for ai = 1:ori_row % 原图像赋值给中间图像，四周边缘设置为0
        for aj = 1:ori_col
            midimg(ai + N, aj + N) = originimg(ai, aj);
        end
    end

    for ai = N + 1:ori_row + N
        for aj = N + 1:ori_col + N
            temp_row = ai - N;
            temp_col = aj - N;
            temp = 0;

            for bi = 1:N_row
                for bj = 1:N_row
                    temp = temp + (midimg(temp_row + bi - 1, temp_col + bj - 1) * H(bi, bj));
                end
            end
            desimg(temp_row, temp_col) = temp;
        end
    end
    desimg = uint8(desimg);

    % 直方图均衡化
    I1 = histeq(blur, 2);

    % 二值化
    thresh2 = graythresh(desimg); % 针对灰度图自动确定二值化阈值
    I2 = imbinarize(desimg,0.75);

    % 去除小的像素聚类
    I5 = bwareaopen(I2, 65);

   
    % 保存处理后的图像
    [~, filenameWithoutExtension, ~] = fileparts(filename);
    outputFilename = fullfile(outputFolder, [filenameWithoutExtension '.bmp']);
    imwrite(I5, outputFilename);

    fprintf('Processed image saved: %s\n', outputFilename);
end

fprintf('Processing completed.\n');
