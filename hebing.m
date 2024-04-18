% 设置输入和输出文件夹路径
sourceFolder = uigetdir('Select the source folder');
destinationFolder = uigetdir('Select the destination folder');

% 调用函数将所有子文件夹中的文件提取到目标文件夹
extractFilesFromSubfolders(sourceFolder, destinationFolder);

% 递归遍历文件夹并将所有文件提取到目标文件夹
function extractFilesFromSubfolders(sourceFolder, destinationFolder)
    % 获取源文件夹中的所有文件和子文件夹
    fileList = dir(sourceFolder);
    
    % 遍历源文件夹中的所有文件和子文件夹
    for i = 1:numel(fileList)
        % 忽略特殊文件夹（'.'和'..'）
        if strcmp(fileList(i).name, '.') || strcmp(fileList(i).name, '..')
            continue;
        end
        
        % 构建当前文件或子文件夹的完整路径
        itemPath = fullfile(sourceFolder, fileList(i).name);
        
        % 检查是否为文件
        if fileList(i).isdir
            % 如果是子文件夹，则递归调用本函数继续处理子文件夹
            extractFilesFromSubfolders(itemPath, destinationFolder);
        else
            % 如果是文件，则将文件复制到目标文件夹中
            [~, filename, fileExt] = fileparts(fileList(i).name);
            destinationFile = fullfile(destinationFolder, [filename, fileExt]);
            copyfile(itemPath, destinationFile);
        end
    end
end