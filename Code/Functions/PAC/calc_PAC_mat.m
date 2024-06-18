function PAC_mat = calc_PAC_mat(sig1, sig2, f_theta, f_gamma, fs)

    PAC_mat = zeros(length(f_theta), length(f_gamma)) ;

    w1 = rid_rihaczek(sig1,fs) ; 
    w2 = rid_rihaczek(sig2,fs) ; 

    for i = f_theta
        k = 0 ; 
        for j = f_gamma
            k = k + 1; 
            PAC_mat(i -1, k) = tfMVL(w1,w2,j,i) ; 
        end
    end

end