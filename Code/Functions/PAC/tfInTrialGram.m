function out = tfInTrialGram(x1,x2,Fs,interval,step,f_theta, f_gamma, window_type, nbins, nperm)
    
    % x1: signal 1
    % x1: signal 2
    % Interval: length of the window
    % step: windows sweap length
    % fGamma: [f_min_gamma f_max_gamma]
    % f_step: for gamma band
    % thetaBand: e.g. [4 8]
    % window_type = causal , anticausal , semi-causal
    
    [~,sz] = size(x1) ;
    if window_type == "causal"
        s_range = interval+1 : step : sz;
        start_idx = interval;
        end_idx = 0;
    elseif window_type == "anticausal"
        s_range = 1 : step : sz-interval;
        start_idx = 0;
        end_idx = interval;
    elseif window_type == "semi-causal"
        s_range = round(interval/2)+1 : step : sz-round(interval/2);
        start_idx = round(interval/2);
        end_idx = round(interval/2);
    end
    
    w1 = nf_cwt(x1,Fs, max(f_gamma)); 
    w2 = nf_cwt(x2,Fs, max(f_gamma));
    
    f_high_idx = find(abs(w1.freqs - f_gamma(1)) < 5*1e-1) : find(abs(w1.freqs - f_gamma(end)) < 10*1e-1);
    f_high = w1.freqs(f_high_idx);
    Amp = sqrt(w1.power(f_high_idx,:));

    f_low_idx = find(abs(w2.freqs - f_theta(1)) < 10*1e-1) : find(abs(w2.freqs - f_theta(end)) < 10*1e-1);
    f_low = w2.freqs(f_low_idx);
    Phase = w2.phase(f_low_idx, :);
    
    table = [] ; 
    
    for s = s_range
        
        window_idx = s-start_idx : s-end_idx;
        
        PAC = calc_MI(Phase(:, window_idx), Amp(:, window_idx), nbins, nperm);
        table = [table; mean(PAC, 1)];
        
    end
        
    out = struct(           ...
        's', s_range,       ...
        'table', table,     ...
        'f_high', f_high,   ...
        'f_low', f_low      ...
    );
    
end