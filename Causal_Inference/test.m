T = readtable('uv_area_summary.txt', 'Delimiter', '\t');
filenames = T.Filename;

% 向量初始化
N = height(T);
W = zeros(N, 1);
X = zeros(N, 2);  % 第一列是天数，第二列是Area__1000_um2_
Y = T.Area__1500_um2_ ./ T.Area__1000_um2_;

for i = 1:N
    name = T.Filename{i};

    % 判断是 mca 还是 wt
    if startsWith(name, 'mca')
        W(i) = 1;
    elseif startsWith(name, 'wt')
        W(i) = 0;
    else
        W(i) = NaN;
    end

    % 提取天数
    match = regexp(name, '-(\d+)d', 'tokens');
    if ~isempty(match)
        day = str2double(match{1}{1});
    else
        day = NaN;
    end

    % 构建 X 向量的两列：天数和1000面积
    X(i, :) = [day, T.Area__1000_um2_(i) / 1e6];
end

record = model2_MCMC(Y, [ones(N,1),X], W, 100000, 20000);
mean(record.tau_fs)
std(record.tau_fs)

record = model3_MCMC(Y, [ones(N,1),X], W, 100000, 20000);
mean(record.tau_fs)
std(record.tau_fs)
