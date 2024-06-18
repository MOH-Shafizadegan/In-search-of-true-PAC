function [MVL] = calc_MVL(Phase,Amp)
    
    z1 = (exp(1i*Phase));
    z = Amp.*(z1);% Generate complex valued signal
    MVL = abs(mean(z));
    
end