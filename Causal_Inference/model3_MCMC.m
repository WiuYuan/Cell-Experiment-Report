function record = model3_MCMC(Y, X, W, max_iter, burn_in)
    Nc = sum(W == 0);
    Nt = sum(W == 1);
    M = size(X, 2);
    Y0 = Y;
    Y1 = Y;
    betac = randn(M, 1) * 100;
    betat = randn(M, 1) * 100;
    I = eye(M);
    record.tau_fs = zeros(max_iter - burn_in, 1);
    record.tau_q25 = zeros(max_iter - burn_in, 1);
    record.tau_q50 = zeros(max_iter - burn_in, 1);
    record.tau_q75 = zeros(max_iter - burn_in, 1);

    for t = 1:max_iter
        sigma2c = 1 / gamrnd(1 + Nc / 2, 1 / (0.01 + sum((Y(W == 0) - X(W == 0, :) * betac) .^ 2) / 2));
        sigma2t = 1 / gamrnd(1 + Nt / 2, 1 / (0.01 + sum((Y(W == 1) - X(W == 1, :) * betat) .^ 2) / 2));
        inv_cov_c = I / 10000 + X(W == 0, :)' * X(W == 0, :) / sigma2c;
        Lc = chol(inv_cov_c, "lower");
        inv_cov_t = I / 10000 + X(W == 1, :)' * X(W == 1, :) / sigma2t;
        Lt = chol(inv_cov_t, "lower");
        betac = Lc' \ (Lc \ (X(W == 0, :)' * Y(W == 0) / sigma2c)) + Lc' \ randn(M, 1);
        betat = Lt' \ (Lt \ (X(W == 1, :)' * Y(W == 1) / sigma2t)) + Lt' \ randn(M, 1);

        if t > burn_in
            Y0(W == 1) = X(W == 1, :) * betac + randn(Nt, 1) * sqrt(sigma2c);
            Y1(W == 0) = X(W == 0, :) * betat + randn(Nc, 1) * sqrt(sigma2t);
            record.tau_fs(t - burn_in) = mean(Y1 - Y0);
            record.tau_q25(t - burn_in) = quantile(Y1, 0.25) - quantile(Y0, 0.25);
            record.tau_q50(t - burn_in) = quantile(Y1, 0.50) - quantile(Y0, 0.50);
            record.tau_q75(t - burn_in) = quantile(Y1, 0.75) - quantile(Y0, 0.75);
        end

    end

end
