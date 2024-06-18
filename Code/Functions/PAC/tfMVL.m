function [tf_canolty] = tfMVL(w1,w2,high_freq,low_freq)

    % This function computes the phase amplitude coupling using TF-MVL method.

    % Input:   w1, w2       : rid-rihaczek output 
    %          high_freq    : Amplitude Frequency range (single freq)
    %          low_freq     : Phase Frequency range 
    %          Fs           : Sampling Frequency  

    % Output:  tf_canolty   : Computed PAC using TF-MVL method


    % Written by: Tamanna T. K. Munia, January 2019
    % Please cite: Munia, Tamanna TK, and Selin Aviyente. "time-frequency Based phase-Amplitude 
    % coupling Measure for neuronal oscillations." Scientific reports 9, no. 1 (2019): 1-15.

    % These scripts have been optimised for the Windows operating systm  
    % MATLAB version used 2018a.

    % Amplitude and Phase calculation

    W21 = w1(2:end,:);


    W22 = w2(2:end,:);

    Amp = abs(W21(high_freq:high_freq,:));
    tfd_low = (W22(low_freq:low_freq,:));
    angle_low = angle(tfd_low);
    Phase = angle_low;

    tf_canolty = (calc_MVL(Phase,Amp));
    
    n_synth = 200;
    synth_canolty = zeros(1,n_synth);
    for i=1:n_synth
        Amp = Amp(randperm(length(Amp)));
        synth_canolty(i) = (calc_MVL(Phase,Amp));
    end

end
