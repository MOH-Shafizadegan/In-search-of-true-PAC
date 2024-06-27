function [PAC,time,fph,famp] = calc_PAC_varTime(sig_ph,sig_amp,Fs,fph,famp,twin,tovp,method,fres_param,nperm,nbins)
% Inputs:
% - sig_ph: The time series to extract the instantaneous phase from it.
% - sig_amp: The time series to extract the instantaneous amplitude from it.
% - Fs: Samplig Rate in Hz
% - fph: Must be a two element vector for the interval of phase frequency.
%        e.g: fph = [4,8]
% - famp: Must be a two element vector for the interval of amplitude 
%         frequency. e.g: famp = [40,80]
% - twin: The window size in each sliding window in seconds. 
%         e.g: twin = 0.5 (0.5 seconds)
% - tovp: The overlap percentage between each window. It have to be between
%          0 and 1. e.g: tovp = 0.9 (90% overlap between sliding windows)
% - method: An string to determine the method of time frequency
%           decomposition. It can be "wavelet" or "rid-rihaczek"
% - fres_param: The parameter of frequency resolution in each method. For
%               'wavelet' method, it can be between 10 to 48. Higher 
%               fres_param ends to higher frequency resolution, but higer 
%               compution cost. For 'rid-rihaczek' method, it means the 
%               interval of each pair of frequency samples.
%               e.g: fres_param = 0.5 -> f = 0, 0.5, 1, 1.5, ...
% - nperm: Number of surrogates for permutation test. Leave it 0 if you
%          don't want use permutation tests.
% - nbins: The number of phase bins for calculation of Modulaiton Index (MI)
% 
% Outputs:
% - PAC: A 3D tensor that is [time]*[phase_freq]*[amplitude_freq]
% - time: The time vector in seconds.
% - fph: Phase frequency vector in hertz.
% - famp: Amplitude frequency vector in hertz.
%
% by Matin Arman Mehr
% E-Mail me for any issues: matinarmanmehr@proton.me

%% Determination of default values

if length(sig_ph)~=length(sig_amp)
    error('Phase and Amplitude signals must have the same length!')
end

if ~exist('method','var') || isempty(method)
    method = "wavelet";
end

if ~exist('nperm','var') || isempty(nperm)
    nperm = 0;
end

if ~exist('nbins','var') || isempty(nbins)
    nbins = 6;
end

if ~exist('fres_param','var') || isempty(fres_param)
    switch lower(string(method))
        case "wavelet"
            fres_param = 10;
        case "rid-rihaczek"
            fres_param = 1;
        otherwise
            error('Unknown method!')
    end
end

%% Finding PAC

% Getting time vector
t = (0:length(sig_ph)-1)/Fs;

switch lower(string(method))
    case "wavelet"

    % Getting t-f distribution
    fb = cwtfilterbank('Wavelet','amor','SignalLength',length(t),'FrequencyLimits',[0,max(famp)],'SamplingFrequency',Fs,'VoicesPerOctave',fres_param);
    [tfd1,ff,cod] = cwt(sig_ph,FilterBank=fb);

    % Check for equality of signals
    if sig_ph == sig_amp
        tfd2 = tfd1;
    else
        [tfd2,~,~] = cwt(sig_amp,FilterBank=fb);
    end
    
    % Trimming the start and end of the window
    idx_start = find(cod<fph(1),1,'first');
    idx_end = length(t) - idx_start + 1;
    t = t(idx_start:idx_end);
    tfd1 = tfd1(:,idx_start:idx_end);
    tfd2 = tfd2(:,idx_start:idx_end);

    fph = ff(ff>=fph(1) & ff<=fph(end));
    famp = ff(ff>=famp(1) & ff<=famp(end));
    
    % Calculation of the Phase and Amplitude
    Phase = angle(tfd1(ismember(ff,fph),:));
    Phase(Phase<0) = 2*pi+Phase(Phase<0);
    Amp = abs(tfd2(ismember(ff,famp),:));

    % Getting the time windows
    t_int_idx = buffer(1:length(t),round(twin*Fs),round(twin*Fs*tovp))';
    [r,~] = find(t_int_idx==0);
    t_int_idx(r,:) = []; 
    time = median(t(t_int_idx),2);
    PAC = zeros(length(time),length(fph),length(famp));

    % Reshape to be used in parfor
    Phase_temp = zeros(size(Phase,1),length(time),size(t_int_idx,2));
    Amp_temp = zeros(size(Amp,1),length(time),size(t_int_idx,2));
    for ti = 1:length(time)
        Phase_temp(:,ti,:) = Phase(:,t_int_idx(ti,:));
        Amp_temp(:,ti,:) = Amp(:,t_int_idx(ti,:));
    end

    % Finding PAC at each window
    parfor ti = 1:length(time)
        disp("Calculation of PAC: Progress: "+ti/length(time)*100+"%")
        PAC(ti,:,:) = myPAC_MI(squeeze(Phase_temp(:,ti,:)),squeeze(Amp_temp(:,ti,:)) , nbins, nperm);
    end

    case "rid-rihaczek"

        % Getting the time windows
        t_int_idx = buffer(1:length(t),round(twin*Fs),round(twin*Fs*tovp))';
        [r,~] = find(t_int_idx==0);
        t_int_idx(r,:) = []; 
        time = median(t(t_int_idx),2);

        sig_ph_buff = buffer(sig_ph,round(twin*Fs),round(twin*Fs*tovp))';
        [r,~] = find(sig_ph_buff==0);
        sig_ph_buff(r,:) = [];

        sig_amp_buff = buffer(sig_amp,round(twin*Fs),round(twin*Fs*tovp))';
        [r,~] = find(sig_amp_buff==0);
        sig_amp_buff(r,:) = [];

        fph = fph(1):fres_param:fph(end);
        famp = famp(1):fres_param:famp(end);

        PAC = zeros(length(time),length(fph),length(famp));
        parfor ti = 1:length(time)
            disp(ti/length(time)*100+"%")

            tfd1 = nf_ridrihaczek(squeeze(sig_ph_buff(ti,:)),Fs,fres_param,[],1);
            if sig_ph_buff(ti,:) == sig_amp_buff(ti,:)
                tfd2 = tfd1;
            else
                tfd2 = nf_ridrihaczek(squeeze(sig_amp_buff(ti,:)),Fs,fres_param,[],1);
            end

            ff = tfd1.freqs;
            Phase = tfd1.phase(ismember(ff,fph),:);
            Amp = tfd2.power(ismember(ff,famp),:);
            
            PAC(ti,:,:) = myPAC_MI(Phase, Amp, nbins, nperm);
        end

    otherwise
        error('Unknown method!')
end

end