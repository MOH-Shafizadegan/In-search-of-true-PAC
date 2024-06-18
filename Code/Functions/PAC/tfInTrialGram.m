function out = tfInTrialGram(x1,x2,Fs,interval,step,thetaBand, fGamma, window_type)
    
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
    
    w1 = nf_cwt(x1,Fs); 
    w2 = nf_cwt(x2,Fs);
    
    table = [] ; 
    
    for s = s_range
        
        window_idx = s-start_idx : s-end_idx;
        
        [MVL, f_high, f_low] = tfMVL(w1, w2, fGamma, thetaBand, window_idx);
        table = [table; mean(MVL, 2)'];
        
    end
        
    out = struct(           ...
        's', s_range,       ...
        'table', table,     ...
        'f_high', f_high,   ...
        'f_low', f_low      ...
    );
    
end