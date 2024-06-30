function [PAC, f_high, f_low] = calc_PAC_mat(sig1, sig2, f_theta, f_gamma, Fs, nbins, nperm)

    w1 = nf_ridrihaczek(sig1,Fs, [], [], 1); 
    w2 = nf_ridrihaczek(sig2,Fs, [], [], 1);
    
    f_high_idx = find(abs(w1.freqs - f_gamma(1)) < 5*1e-1) : find(abs(w1.freqs - f_gamma(end)) < 10*1e-1);
    f_high = w1.freqs(f_high_idx);
    Amp = w1.power(f_high_idx,:);

    f_low_idx = find(abs(w2.freqs - f_theta(1)) < 10*1e-1) : find(abs(w2.freqs - f_theta(end)) < 10*1e-1);
    f_low = w2.freqs(f_low_idx);
    Phase = w2.phase(f_low_idx, :);
    
    PAC = calc_MI(Phase, Amp, nbins, nperm);

end