clc; clear; close all;

addpath('./Functions')
addpath('./Functions/PAC')
addpath('./Functions/Visualization')

%% Generate signal

Fs = 1000;               % Sampling frequency (Hz)
SNR = 1;                 % Signal to Noise Ratio
addnoise_var = 0.2;     % Additive noise to the couple signal which is
                         % needed for precise PAC calculation (In SNR=inf
                         % the PAC methods won't work well)

sig1 = generate_sig(T1, K_f_p1, K_f_a1, f_p1, f_a1, c_frac1, Fs);
sig1 = sig1 + addnoise_var*randn(1,length(sig1));

sig2 = generate_sig(T2, K_f_p2, K_f_a2, f_p2, f_a2, c_frac2, Fs);
sig2 = sig2 + addnoise_var*randn(1,length(sig2));

n1_pow = mean(sig1.^2) * 10^(-SNR/10);
n2_pow = mean(sig2.^2) * 10^(-SNR/10);

noise = max(n1_pow,n2_pow) * randn(1,length(sig1));

sig1_noisy = sig1 + n1_pow * randn(1,length(sig1));
sig2_noisy = sig2 + n2_pow * randn(1,length(sig2));

signal = [noise sig1 sig2 sig1_noisy sig2_noisy];

%% Visualize signal

t = 0:1/Fs:1-(1/Fs);
t_all = 0:1/Fs:length(signal)/Fs-(1/Fs);

figure;
subplot(4,1,1)
plot(t, noise(1:length(t)));
title('Random Gussian Noise');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(4,1,2)
plot(t, sig1(1:length(t)));
title('fp=5, fa=40');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(4,1,3)
plot(t, sig2(1:length(t)));
title('fp=9, fa=60');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(4,1,4)
plot(t_all, signal);
title("All Signal (SNR: "+SNR+"dB)");
xlabel('Time (s)');
ylabel('Amplitude');

%% PAC comodu

% PAC Method:
%     - New rid-rihaczek function (Neuro_Freq)
%     - First calculating tf-decomposition, then Windowing

[PAC_mat_noise, f_high, f_low] = calc_PAC_mat(noise, noise, 2:13, 20:90, Fs);
PAC_mat_sig1 = calc_PAC_mat(sig1, sig1, 2:13, 20:90, Fs);
PAC_mat_sig2 = calc_PAC_mat(sig2, sig2, 2:13, 20:90, Fs);

%% PAC comodu Visualization

range = max([max(max(PAC_mat_sig1)) max(max(PAC_mat_sig2)) max(max(PAC_mat_noise))])

plot_comodulogram(PAC_mat_noise, f_high, f_low, [0 range])
save_path = './Results/PAC_comodu/';
fig_title = strcat('PAC-comodu-sig-randomNoise');
save_fig(save_path, fig_title);

plot_comodulogram(PAC_mat_sig1, f_high, f_low, [0 range])
save_path = './Results/PAC_comodu/';
fig_title = strcat('PAC-comodu-synth-sig-fp', num2str(f_p1), '-fa', num2str(f_a1));
save_fig(save_path, fig_title);

plot_comodulogram(PAC_mat_sig2, f_high, f_low, [0 range])
save_path = './Results/PAC_comodu/';
fig_title = strcat('PAC-comodu-synth-sig-fp', num2str(f_p2), '-fa', num2str(f_a2));
save_fig(save_path, fig_title);

%% PAC dynamic

% Checkout the new funcitons results

twin = 0.5; % Window size in seconds
tovp = 0.95; % Overlap percentage
fph = [3,10]; % Phase frequency range
famp = [20,100]; % Amplitude frequcny range
method = 'wavelet';
fres_param = 32;
nperm = 0;
nbins = 18;

[PAC, time_PAC, fph_vec, famp_vec] = calc_PAC_varTime(signal,signal,Fs,fph,famp,twin,tovp,method,fres_param,nperm,nbins);

% Getting mean over phase frequency
PAC_m = squeeze(mean(PAC,2));

%% Viusalize the PAC dynamics
figure('Units','normalized','Position',[0.1, 0.2, 0.5, 0.5])
pcolor(time_PAC, famp_vec, PAC_m')
shading interp
colormap jet
colorbar
xlabel('Time (s)')
ylabel('f_{Amp} (Hz)')
title('Dynamics of PAC')

xline(T1,'r--',LineWidth=2)
xline(2*T1,'k--',LineWidth=2)
xline(2*T1+T2,'g--',LineWidth=2)
xline(2*T1+T2+T1,'m--',LineWidth=2)
legend({'PAC','sig1','sig2','sig1 + noise','sig2 + noise'})


%% Statistical analysis

% coupling 1: fp=[4 7], fa=[38 42]
sample_size = 100;
T1 = 1;
coupling1_sigs = zeros(sample_size, T1*Fs);
for i=1:sample_size
    K_f_p1=randn(1); K_f_a1=randn(1); f_p1=randi([4, 7], 1); f_a1=randi([38, 42], 1); c_frac1=0;
    sig = generate_sig(T1, K_f_p1, K_f_a1, f_p1, f_a1, c_frac1, Fs);
    coupling1_sigs(i,:) = sig;
end

% coupling 2: fp=[8 12], fa=[55 65]
T2 = 1;
coupling2_sigs = zeros(sample_size, T2*Fs);
for i=1:sample_size
    K_f_p1=randn(1); K_f_a1=randn(1); f_p1=randi([8, 11], 1); f_a1=randi([55, 65], 1); c_frac1=0;
    sig = generate_sig(T1, K_f_p1, K_f_a1, f_p1, f_a1, c_frac1, Fs);
    coupling2_sigs(i,:) = sig;
end

coupling1_PAC = zeros(sample_size, 1);
coupling2_PAC = zeros(sample_size, 1);
for i=1:sample_size
    PAC1 = tfInTrialGram(coupling1_sigs(i,:), coupling1_sigs(i,:), Fs, Fs-1,...
                           1, theta_band, ...
                           gamma_band, window_type);
    PAC2 = tfInTrialGram(coupling2_sigs(i,:), coupling2_sigs(i,:), Fs, Fs-1,...
                           1, theta_band, ...
                           gamma_band, window_type);
    
    coupling1_PAC(i) = mean(PAC1.table, 2);
    coupling2_PAC(i) = mean(PAC2.table, 2);
    disp(i)
end

%% Pvalue

[~, pval] = ttest2(coupling2_PAC, coupling1_PAC, 'Tail', 'left', 'Vartype', 'unequal');
disp(pval)
