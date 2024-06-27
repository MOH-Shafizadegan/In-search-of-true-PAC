clc; clear; close all;

addpath('./Functions')
addpath('./Functions/PAC')
addpath('./Functions/Visualization')

%% Generate signal

Fs = 1000;               % Sampling frequency (Hz)
SNR = 1;                 % Signal to Noise Ratio
addnoise_var = 0.2;      % Additive noise to the couple signal which is
                         % needed for precise PAC calculation (In SNR=inf
                         % the PAC methods won't work well)

T1=1; K_f_p1=1; K_f_a1=1; f_p1=5; f_a1=40; c_frac1=0; phi_c1 = rand()*2*pi;
sig1 = generate_sig(T1, K_f_p1, K_f_a1, f_p1, f_a1, c_frac1, phi_c1, Fs);
sig1 = sig1 + addnoise_var*randn(1,length(sig1));

T2=1; K_f_p2=1; K_f_a2=1; f_p2=9; f_a2=60; c_frac2=0; phi_c2 = rand()*2*pi;
sig2 = generate_sig(T2, K_f_p2, K_f_a2, f_p2, f_a2, c_frac2, phi_c2, Fs);
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

figure('WindowState', 'maximized');
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

save_fig('./Results/Sig/', 'Synthesized Signal');

%% PAC comodu

% PAC Method:
%     - Wavelet tf-decomposition
%     - First calculating tf-decomposition, then Windowing

[PAC_mat_noise, f_high, f_low] = calc_PAC_mat(noise, noise, 2:13, 20:90, Fs);
PAC_mat_sig1 = calc_PAC_mat(sig1, sig1, 2:13, 20:90, Fs);
PAC_mat_sig2 = calc_PAC_mat(sig2, sig2, 2:13, 20:90, Fs);
PAC_mat_sig1_noisy = calc_PAC_mat(sig1_noisy, sig1_noisy, 2:13, 20:90, Fs);
PAC_mat_sig2_noisy = calc_PAC_mat(sig2_noisy, sig2_noisy, 2:13, 20:90, Fs);

%% PAC comodu Visualization

range = max([max(max(PAC_mat_sig1)) max(max(PAC_mat_sig2)) max(max(PAC_mat_noise)) ...
             max(max(PAC_mat_sig1_noisy)) max(max(PAC_mat_sig2_noisy))])

plot_comodulogram(PAC_mat_noise, f_high, f_low, [0 range])
save_path = './Results/PAC_comodu/';
fig_title = strcat('PAC-comodu-sig-randomNoise');
save_fig(save_path, fig_title);

plot_comodulogram(PAC_mat_sig1, f_high, f_low, [0 range])
fig_title = strcat('PAC-comodu-synth-sig-fp', num2str(f_p1), '-fa', num2str(f_a1));
save_fig(save_path, fig_title);

plot_comodulogram(PAC_mat_sig2, f_high, f_low, [0 range])
fig_title = strcat('PAC-comodu-synth-sig-fp', num2str(f_p2), '-fa', num2str(f_a2));
save_fig(save_path, fig_title);

plot_comodulogram(PAC_mat_sig1_noisy, f_high, f_low, [0 range])
fig_title = strcat('PAC-comodu-synth-noisy-sig-fp', num2str(f_p1), '-fa', num2str(f_a1));
save_fig(save_path, fig_title);

plot_comodulogram(PAC_mat_sig2_noisy, f_high, f_low, [0 range])
fig_title = strcat('PAC-comodu-synth-noisy-sig-fp', num2str(f_p2), '-fa', num2str(f_a2));
save_fig(save_path, fig_title);


%% PAC dynamic

% We just want to detect the first coupling

interval = 0.2 * Fs -1;
w_step = 0.1 * Fs;
window_type = 'causal';
theta_band = [4 8];
gamma_band = [35 45];

PAC = tfInTrialGram(signal, signal, Fs, interval,...
                           w_step, theta_band, ...
                           gamma_band, window_type);

PAC_dyn = mean(PAC.table, 2);

%% Viusalize the PAC dynamic

figure;
tint = PAC.s / Fs * 1000;
plot(tint, PAC_dyn, 'linewidth', 2);
xlabel('time');
ylabel('PAC');
xlim([0 5000])

save_path = './Results/PAC_dyn/';
fig_title = 'PAC-dyn-sig';
save_fig(save_path, fig_title);


%% Statistical analysis

% coupling 1: fp=[4 7], fa=[38 42]
sample_size = 100;
T1 = 1;
coupling1_sigs = zeros(sample_size, T1*Fs);
for i=1:sample_size
    K_f_p1=randn(1); K_f_a1=randn(1); f_p1=randi([4, 7], 1);
    f_a1=randi([38, 42], 1); phi_c = rand()*2*pi; c_frac1=0;
    sig = generate_sig(T1, K_f_p1, K_f_a1, f_p1, f_a1, c_frac1, phi_c, Fs);
    coupling1_sigs(i,:) = sig;
end

% coupling 2: fp=[8 12], fa=[55 65]
T2 = 1;
coupling2_sigs = zeros(sample_size, T2*Fs);
for i=1:sample_size
    K_f_p1=randn(1); K_f_a1=randn(1); f_p1=randi([8, 11], 1);
    f_a1=randi([55, 65], 1); phi_c = rand()*2*pi; c_frac1=0;
    sig = generate_sig(T1, K_f_p1, K_f_a1, f_p1, f_a1, c_frac1, phi_c, Fs);
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
disp('p-value =')
disp(pval)
save('./Results/p-value.txt', 'pval', '-ascii');  % Saves variable 'x' to 'data.txt'
