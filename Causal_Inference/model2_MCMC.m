function record = model2_MCMC(Y, X, W, max_iter, burn_in)
    Nc = sum(W == 0);
    Nt = sum(W == 1);
    muc = randn * 100;
    mut = randn * 100;
    Y0 = Y;
    Y1 = Y;
    record.muc = zeros(1, max_iter - burn_in);
    record.mut = zeros(1, max_iter - burn_in);
    record.sigma2c = zeros(1, max_iter - burn_in);
    record.sigma2t = zeros(1, max_iter - burn_in);
    record.tau_fs = zeros(1, max_iter - burn_in);
    record.tau_q25 = zeros(1, max_iter - burn_in);
    record.tau_q50 = zeros(1, max_iter - burn_in);
    record.tau_q75 = zeros(1, max_iter - burn_in);

    for t = 1:max_iter
        betac = 0.01 + sum((Y(W == 0) - muc) .^ 2) / 2;
        betat = 0.01 + sum((Y(W == 1) - mut) .^ 2) / 2;
        sigma2c = 1 / gamrnd(1 + Nc / 2, 1 / betac);
        sigma2t = 1 / gamrnd(1 + Nt / 2, 1 / betat);
        muc = sum(Y(W == 0)) / (sigma2c / 10000 + Nc) + randn / sqrt(1 / 10000 + Nc / sigma2c);
        mut = sum(Y(W == 1)) / (sigma2t / 10000 + Nt) + randn / sqrt(1 / 10000 + Nt / sigma2t);

        if t > burn_in
            record.muc(t - burn_in) = muc;
            record.mut(t - burn_in) = mut;
            record.sigma2c(t - burn_in) = sigma2c;
            record.sigma2t(t - burn_in) = sigma2t;
            Y0(W == 1) = muc + randn(Nt, 1) * sqrt(sigma2c);
            Y1(W == 0) = mut + randn(Nc, 1) * sqrt(sigma2t);
            record.tau_fs(t - burn_in) = mean(Y1 - Y0);
            record.tau_q25(t - burn_in) = quantile(Y1, 0.25) - quantile(Y0, 0.25);
            record.tau_q50(t - burn_in) = quantile(Y1, 0.50) - quantile(Y0, 0.50);
            record.tau_q75(t - burn_in) = quantile(Y1, 0.75) - quantile(Y0, 0.75);
        end

    end

end
