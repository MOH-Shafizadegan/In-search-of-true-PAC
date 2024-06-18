function out = tfInTrialGram(x1,x2,Fs,interval,step,thetaBand, fGamma, f_step, window_type)
    
    % x1: signal 1
    % x1: signal 2
    % Interval: length of the window
    % step: windows sweap length
    % fGamma: [f_min_gamma f_max_gamma]
    % f_step: for gamma band
    % thetaBand: e.g. [4 8]
    % window_type = causal , anticausal , semi-causal
    
    [~,sz] = size(x1) ;
    f = fGamma(1) : f_step : fGamma(2) ; 
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
    
    table = zeros(max(size(s_range)),max(size(f))) ; 
    S = 1 ; 
    for s = s_range
        K = 1 ; 
        w1 = rid_rihaczek(x1(s-start_idx : s-end_idx),Fs) ; 
        w2 = rid_rihaczek(x2(s-start_idx : s-end_idx),Fs) ; 
        for f = fGamma(1) : f_step : fGamma(2) 
            MVL = 0;
            for i = thetaBand(1):thetaBand(2)
                MVL = MVL + tfMVL(w1, w2, f, i);
            end
            table(S,K) = MVL / (thetaBand(2)-thetaBand(1) + 1) ; 
            K = K + 1 ; 
        end
        S = S + 1 ;
    end
        
    out = struct( ...
        's', s_range, ...
        'table', table ...
    );
    
end