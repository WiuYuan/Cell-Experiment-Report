// 设置输入输出文件夹
inputDir = "输入路径";
outputDir = "输出路径";
image_num = 3; // 设置导出哪张图片, 从1到3分别为BF Mono, GC, U-FUNA


// 开启批处理模式
setBatchMode(true);

// 获取文件夹中所有文件名
list = getFileList(inputDir);

// 遍历所有文件
for (i = 0; i < list.length; i++) {
    filename = list[i];
    if (endsWith(filename, ".vsi")) {

        // 打开 Bio-Formats MetaData Browser（无图像）
        run("Bio-Formats Importer", 
            "open=[" + inputDir + filename + "] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT split_channels=false split_timepoints=false merge_channels=false");

        // 获取当前图像像素间距（单位为微米）
        getVoxelSize(width, height, depth, unit);
        close(); // 关闭图像窗口（只用来获取像素大小）

        // 判断是否为4倍放大（即像素大小约为1.625微米）如果是导出10倍放大图像, 改为>0.01
        if (abs(width - 1.625) < 0.01) {
            // 重新打开图像
            run("Bio-Formats Importer", 
                "open=[" + inputDir + filename + "] autoscale color_mode=Default windowless=true series_0");

            setSlice(image_num); // 选中切片
            run("Duplicate...", "title=Slice3");

            // 生成输出文件路径
            baseName = replace(filename, ".vsi", "_slice3");
            outPath = outputDir + baseName + ".tif";

            // 如果文件已存在，则添加 -1 后缀
            if (File.exists(outPath)) {
                outPath = outputDir + baseName + "-1.tif";
            }

            // 保存
            saveAs("Tiff", outPath);

            close(); // Slice3
            close(); // 原图
        }
    }
}

// 关闭批处理模式
setBatchMode(false);
