function [MVL] = calc_MVL(Phase,Amp)
    
    % inputs are 2D matrices

    z = Amp * (exp(1i*Phase))';
    MVL = abs(z) ./ size(Amp, 2);

end