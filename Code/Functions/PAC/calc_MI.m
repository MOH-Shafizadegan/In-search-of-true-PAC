function PAC = calc_MI(Phase, Amp, nbins, nperm, fph, Fs)

if ~exist('nperm','var') || isempty(nperm)
    nperm = 0;
end

fphflag = 0;
if exist('fph','var') && ~isempty(fph) && exist('Fs','var') && ~isempty(Fs)
    fphflag = 1;
    fmax_idx = zeros(1,size(Amp,1));
    for fi = 1:size(Amp,1)
        [Amp_f,frq] = myfft(squeeze(Amp(fi,:)),Fs,4*Fs);
        Amp_f = Amp_f(frq>=min(fph) & frq<=max(fph));
        frq = frq(frq>=min(fph) & frq<=max(fph));
        [~,idx] = max(Amp_f);
        [~,~,fmax_idx(fi)] = myVectorSizeEqualizer(fph,frq(idx));
    end
end

if nperm == 0

    % Ordinary MI
    Phase(Phase<0) = 2*pi+Phase(Phase<0);
    P = zeros(1,nbins);
    PAC = zeros(size(Phase,1),size(Amp,1));
    if fphflag
        for fai = 1:size(Amp,1)
            for i = 1:nbins
                P(i) = mean(Amp(fai,Phase(fmax_idx(fai),:)>=(((i-1)/nbins)*2*pi) & Phase(fmax_idx(fai),:)<(i/nbins)*2*pi));
            end
            P(isnan(P)) = 0;
            P = P./sum(P);
            PAC(fmax_idx(fai),fai) = 1+sum(P(P~=0).*log2(P(P~=0)))/log2(nbins);
        end
    else
        for fpi = 1:size(Phase,1)
            for fai = 1:size(Amp,1)
                for i = 1:nbins
                    P(i) = mean(Amp(fai,Phase(fpi,:)>=(((i-1)/nbins)*2*pi) & Phase(fpi,:)<(i/nbins)*2*pi));
                end
                P(isnan(P)) = 0;
                P = P./sum(P);
                PAC(fpi,fai) = 1+sum(P(P~=0).*log2(P(P~=0)))/log2(nbins);
            end
        end
    end

else

    % MI with Permutation Test
    Phase(Phase<0) = 2*pi+Phase(Phase<0);
    P = zeros(1,nbins);
    PAC_raw = zeros(size(Phase,1),size(Amp,1));
    for fpi = 1:size(Phase,1)
        for fai = 1:size(Amp,1)
            for i = 1:nbins
                P(i) = mean(Amp(fai,Phase(fpi,:)>=(((i-1)/nbins)*2*pi) & Phase(fpi,:)<(i/nbins)*2*pi));
            end
            P(isnan(P)) = 0;
            P = P./sum(P);
            PAC_raw(fpi,fai) = 1+sum(P(P~=0).*log2(P(P~=0)))/log2(nbins);
        end
    end
    PAC = zeros(size(Phase,1),size(Amp,1),nperm);
    for n = 1:nperm
        P = zeros(1,nbins);
        for fpi = 1:size(Phase,1)
            for fai = 1:size(Amp,1)
                Amp_perm = Amp(fai,randperm(size(Amp,2)));
                for i = 1:nbins
                    P(i) = mean(Amp_perm(Phase(fpi,:)>=(((i-1)/nbins)*2*pi) & Phase(fpi,:)<(i/nbins)*2*pi));
                end
                P(isnan(P)) = 0;
                P = P./sum(P);
                PAC(fpi,fai,n) = 1+sum(P(P~=0).*log2(P(P~=0)))/log2(nbins);
            end
        end
    end
    PAC = (PAC_raw - mean(PAC,3))./std(PAC,[],3);
    PAC(PAC<1.7) = 0;

end

end
