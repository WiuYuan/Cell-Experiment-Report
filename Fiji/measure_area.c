// 设置输入和输出路径
inputDir = "输入路径";
outputFile = "输出路径";

// 获取文件列表
list = getFileList(inputDir);

// 初始化输出文件内容
header = "Filename\tArea_>1500(um2)\tArea_>1000(um2)\n";
File.saveString(header, outputFile);

// 开启批处理
setBatchMode(true);

for (i = 0; i < list.length; i++) {
    filename = list[i];
    if (endsWith(filename, ".tif")) {
        open(inputDir + filename);

        // 设置显示亮度对比度（可视化，不影响面积分析）
        setMinAndMax(400, 3000);

        // 获取像素面积（单位是 µm²）
        getVoxelSize(voxelWidth, voxelHeight, voxelDepth, unit);
        pixelArea = voxelWidth * voxelHeight;

        // -------- 计算亮度 >1500 的面积 --------
        setThreshold(1500, 65535);
        run("Convert to Mask");
        run("Set Measurements...", "area redirect=None decimal=3");
        run("Analyze Particles...", "size=0-Infinity clear summarize");

        area1500 = 0;
        for (r = 0; r < nResults; r++) {
            area1500 += getResult("Area", r);
        }

        close(); // mask

        // -------- 重新打开原图并计算亮度 >1000 的面积 --------
        open(inputDir + filename);
        setMinAndMax(400, 3000);
        setThreshold(1000, 65535);
        run("Convert to Mask");
        run("Set Measurements...", "area redirect=None decimal=3");
        run("Analyze Particles...", "size=0-Infinity clear summarize");

        area1000 = 0;
        for (r = 0; r < nResults; r++) {
            area1000 += getResult("Area", r);
        }

        close(); // mask
        run("Clear Results");

        // -------- 写入文件 --------
        line = filename + "\t" + area1500 + "\t" + area1000 + "\n";
        File.append(line, outputFile);
    }
}

// 关闭批处理模式
setBatchMode(false);

// 提示完成
print("✅ 提取完成，结果已保存至: " + outputFile);
