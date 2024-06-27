function sig = generate_sig(T, K_f_p, K_f_a, f_p, f_a, c_frac, Fs)
    
    t = 0:1/Fs:T-(1/Fs);

    A_f_a = K_f_a * ((1 - c_frac)* sin(2*pi*f_p.*t + rand()*2*pi) + 1 + c_frac) / 2; 

    x_f_p = K_f_p * sin(2*pi*f_p.*t);
    x_f_a = A_f_a .* sin(2*pi*f_a.*t);

    sig = x_f_p + x_f_a;

end