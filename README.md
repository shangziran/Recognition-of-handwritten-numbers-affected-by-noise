# Recognition-of-handwritten-numbers-affected-by-noise
基于Matlab的噪声影响手写数字降噪与识别 Noise reduction and recognition of handwritten numbers affected by noise based on Matlab

点击app1这个可以在matlab运行（需要image process tools），使用train_images文件里的手写数字图像按流程处理，也可以用origin里小一些的数据集。具体可看使用说明书。




1）训练样本降噪模块
此模块在用户点击“训练样本降噪处理”按钮后，选择输入输出的训练样本文件夹，程序开始对所有样本图片进行高斯降噪、二值化、去小像素块处理，将处理好样本图片保存到输出文件夹。
2）训练样本切块模块
本模块可实现将前一步得到样本切块处理。用户点击“训练样本切块处理”后选择输入输出文件夹就会将切割好的样本图片保存在样本同名文件夹中并按编号排好。
3）合并样本模块
此模块将前一模块得到的不同文件夹的样本合并到同一文件夹。用户点击“合并样本处理”按钮并选取输入输出文件夹路径后，将执行合并操作。
4）KNN 模型训练模块
此模块将前一模块得到处理好的训练样本进行 KNN 训练得到可用于识别的模型。用户点击“KNN 模型训练”按钮并选取输入文件夹路径后，将自动划分训练集验证集进行 KNN训练，并将得到的模型以及模型混淆概率矩阵保存到程序同一路径下。
5）手写数字图片预测模块
此模块需要有前面模块训练好的 KNN 模型，用户点击“手写数字图片预测”后，选择需要识别的手写数字图片，模块将先进行降噪二值化以及调整大小处理，再与模型比对特征，最后在消息框显示识别结果。
