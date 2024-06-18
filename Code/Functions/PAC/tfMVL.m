function [tf_canolty, f_high, f_low] = tfMVL(w1,w2,high_freq,low_freq, window_idx)

    % This function computes the phase amplitude coupling using TF-MVL method.

    % Input:   w1, w2       : tf decomposition outputs 
    %          high_freq    : Amplitude Frequency range
    %          low_freq     : Phase Frequency range 
    %          Fs           : Sampling Frequency  

    % Output:  tf_canolty   : Computed PAC using TF-MVL method

    f_high_idx = find(abs(w1.freqs - high_freq(1)) < 5*1e-1) : find(abs(w1.freqs - high_freq(end)) < 10*1e-1);
    f_high = w1.freqs(f_high_idx);
    Amp = sqrt(w1.power(f_high_idx,window_idx));

    f_low_idx = find(abs(w2.freqs - low_freq(1)) < 5*1e-1) : find(abs(w2.freqs - low_freq(end)) < 10*1e-1);
    f_low = w2.freqs(f_low_idx);
    Phase = w2.phase(f_low_idx, window_idx);

    tf_canolty = (calc_MVL(Phase,Amp));
    
end
