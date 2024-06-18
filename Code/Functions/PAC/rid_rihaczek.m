function [tfd]=rid_rihaczek(x,fbins)

    % This function computes reduced interference Rihaczek distribution;
    % Input: x: signal (ERP), fbins=required frequency bins (fs)
    % Output: tfd = Generated reduced interference Rihaczek distribution

    tbins = length(x);
    amb = zeros(tbins);

    for tau = 1:tbins
        amb(tau,:) = (conj(x) .* x([tau:tbins 1:tau-1]) );
    end

    ambTemp = [amb(:,tbins/2+1:tbins) amb(:,1:tbins/2)];
    amb1 = [ambTemp(tbins/2+1:tbins,:); ambTemp(1:tbins/2,:)];

    D=(-1:2/(tbins-1):1)'*(-1:2/(tbins-1):1);
    L=D;
    K=chwi_krn(D,L,0.01);
    [s,d]=size(amb1);
    df=K(1:s,1:d);
    ambf = amb1 .* df;

    A = zeros(fbins,tbins);
    tbins=tbins-1;
    if tbins ~= fbins
        for tt = 1:tbins
            A(:,tt) = datawrap(ambf(:,tt), fbins);
        end
    else
        A = ambf; 
    end

    tfd = fft(A);

end
