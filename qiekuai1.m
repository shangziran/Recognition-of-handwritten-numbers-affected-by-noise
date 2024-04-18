% 设置输入和输出文件夹路径
inputFolder = uigetdir('Select the input folder');
outputFolder = uigetdir('Select the output folder');

% 创建输出文件夹
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% 获取输入文件夹中的所有BMP图像文件
fileList = dir(fullfile(inputFolder, '*.bmp'));

% 循环处理每个输入图像文件
for i = 1:numel(fileList)
    % 读取输入的二值BMP图像
    filename = fullfile(inputFolder, fileList(i).name);
    inputImg = imread(filename);

    % 创建当前图像的输出文件夹
    imageOutputFolder = fullfile(outputFolder, fileList(i).name(1:end-4));
    if ~exist(imageOutputFolder, 'dir')
        mkdir(imageOutputFolder);
    end

    % 连通区域标记矩阵
    labeledImg = zeros(size(inputImg));

    % 当前连通区域的标记值
    label = 1;

    % 循环遍历图像的每个像素
    for row = 1:size(inputImg, 1)
        for col = 1:size(inputImg, 2)
            % 如果当前像素是前景像素且未被标记
            if inputImg(row, col) == 1 && labeledImg(row, col) == 0
                % 使用深度优先搜索进行连通区域标记
                labeledImg = dfs(inputImg, labeledImg, row, col, label);
                label = label + 1;
            end
        end
    end

    % 提取字符区域并保存为28x28像素大小的BMP文件
    for l = 1:label-1
        % 找到当前连通区域的所有像素坐标
        [rows, cols] = find(labeledImg == l);

        % 计算字符区域的边界框
        minRow = min(rows);
        maxRow = max(rows);
        minCol = min(cols);
        maxCol = max(cols);

        % 截取字符区域
        charImg = inputImg(minRow:maxRow, minCol:maxCol);

        % 检查字符区域是否大于等于10x10像素
        if size(charImg, 1) >= 10 && size(charImg, 2) >= 10
            % 调整图像大小为28x28像素
            charImgResized = imresize(charImg, [28, 28]);

            % 生成保存路径和文件名
            [~, filenameWithoutExtension, ~] = fileparts(filename);
            charFilename = fullfile(imageOutputFolder, [filenameWithoutExtension, '_', num2str(l), '.bmp']);

            % 保存字符区域为单独的BMP文件
            imwrite(charImgResized, charFilename);
        end
    end
end

% 深度优先搜索函数
function labeledImg = dfs(inputImg, labeledImg, row, col, label)
    % 标记当前像素
    labeledImg(row, col) = label;

    % 定义上、下、左、右四个方向的相对坐标
    directions = [-1, 0; 1, 0; 0, -1; 0, 1];

    % 循环遍历四个方向
    for d = 1:size(directions, 1)
        % 计算相邻像素的坐标
        newRow = row + directions(d, 1);
        newCol = col + directions(d, 2);

        % 检查相邻像素是否在图像范围内且是前景像素且未被标记
        if newRow >= 1 && newRow <= size(inputImg, 1) && newCol >= 1 && newCol <= size(inputImg, 2) && inputImg(newRow, newCol) == 1 && labeledImg(newRow, newCol) == 0
            % 递归调用深度优先搜索
            labeledImg = dfs(inputImg, labeledImg, newRow, newCol, label);
        end
    end
end
