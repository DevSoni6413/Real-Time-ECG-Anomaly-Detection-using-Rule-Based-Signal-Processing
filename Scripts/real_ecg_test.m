clc
clear
close all
rng('shuffle')

% ============================================================
% READ DATASET
% ============================================================
data = readmatrix("C:\matlab_project\embedded_biomedical_project\ECG_dataset\mitbih_folder\mitbih_train.csv");

% ============================================================
% SELECT 5 RANDOM ROWS AND COMBINE
% ============================================================
% Get all class 0 row indices
total_rows = size(data, 1);
row = randi(total_rows, 1, 5);

disp("Rows selected (random, all classes):")
disp(row)

combined_ecg = [];
for i = 1:5
    ecg = data(row(i), 1:187);
    ecg = ecg(ecg ~= 0);       % remove zero-padding
    combined_ecg = [combined_ecg, ecg];
end

label = data(row, 188);
disp("Class Labels (0=Normal, 1=S, 2=V, 3=F, 4=Q):")
disp(label)

% ============================================================
% SIGNAL PARAMETERS
% ============================================================
fs = 125;
t  = (0:length(combined_ecg)-1) / fs;

% ============================================================
% LOW-PASS FILTER
% ============================================================
filtered = lowpass(combined_ecg, 30, fs);

% ============================================================
% EXPORT MAX AMPLITUDE FOR SIMULINK ADAPTIVE THRESHOLD
% RC1 FIX: Simulink must use same adaptive threshold as script
% ============================================================
ECG_max_amp = max(filtered);
assignin('base', 'ECG_max_amp', ECG_max_amp);
fprintf("ECG max amplitude (exported to base workspace): %.4f\n", ECG_max_amp)

% ============================================================
% PEAK DETECTION
% ============================================================
height     = 0.6 * ECG_max_amp;
distance   = round(0.2 * fs);        % 25 samples
prominence = 0.3 * ECG_max_amp;

[pks, locs, width] = findpeaks(filtered, ...
    'MinPeakHeight',     height, ...
    'MinPeakDistance',   distance, ...
    'MinPeakProminence', prominence, ...
    'MaxPeakWidth',      8);


if isempty(pks)
    disp("No R peaks detected — abnormal ECG morphology")
    return
elseif length(pks)<3
    disp("Insufficient peaks detected - signal quality too poor for analysis")
    disp("Re-run the script to select diff rows")
    return
end

disp("Peak amplitudes:");   disp(pks)
disp("Peak locations (samples):"); disp(locs)
fprintf("Peak times (seconds): "); disp(locs/fs)
disp("Peak widths:"); disp(width)

% ============================================================
% RR INTERVALS AND BPM
% ============================================================
peak_gaps = diff(locs);
RR        = peak_gaps / fs;           % RR intervals in seconds
disp("RR intervals (seconds):"); disp(RR)

BPM = 60 / mean(RR);
% Export mean RR to Simulink for pre-warming
mean_RR_samples = mean(RR) * fs;   % convert seconds to samples
assignin('base', 'mean_RR_init', mean_RR_samples);

fprintf("BPM: %.2f\n", BPM)

% ============================================================
% HEART RATE STATUS
% ============================================================
if BPM > 100
    disp("Tachycardia detected")
elseif BPM < 55
    disp("Bradycardia detected")
else
    disp("Normal heart rate")
end

% ============================================================
% SENSOR DISCONNECT
% ============================================================
if max(abs(filtered)) < 0.1
    disp("Sensor disconnected!")
else
    disp("Sensor connected")
end

% ============================================================
% RHYTHM VARIATION
% ============================================================
if length(RR) > 1
    variation = std(RR);
    fprintf("RR std deviation: %.4f s\n", variation)
    if variation < 0.1
        disp("Regular rhythm")
    else
        disp("Irregular rhythm")
    end
end

% ============================================================
% MISSING BEAT DETECTION
% ============================================================
if any(RR > 1.5 * mean(RR))
    disp("Missing heartbeat detected!")
else
    disp("No missing beat")
end

% ============================================================
% PREMATURE BEAT — RC4 FIX: Use CONSECUTIVE counting to match Simulink
% ============================================================
early = RR < 0.8 * mean(RR);

consec     = 0;
max_consec = 0;
for k = 1:length(early)
    if early(k)
        consec     = consec + 1;
        max_consec = max(max_consec, consec);
    else
        consec = 0;
    end
end

if max_consec >= 2
    disp("Repeated consecutive premature beats detected")
elseif any(early)
    disp("Premature beat detected")
else
    disp("No premature beat")
end

% ============================================================
% R SPIKE CONDITION — statistical comparison (matches Simulink)
% ============================================================
if length(pks) >= 2
    if max(pks) > 1.5 * mean(pks)
        disp("Abnormally high R spike")
    elseif min(pks) < 0.5 * mean(pks)
        disp("Abnormally weak R spike")
    else
        disp("Normal R spike")
    end
end

% ============================================================
% PLOTTING
% ============================================================
figure
subplot(3,1,1)
plot(t, combined_ecg, 'r')
title("Raw ECG Signal")
xlabel("Time (s)"); ylabel("Amplitude")

subplot(3,1,2)
plot(t, filtered, 'c')
title("Filtered ECG (Low-pass 30 Hz)")
xlabel("Time (s)"); ylabel("Amplitude")

subplot(3,1,3)
plot(t, filtered, 'g')
hold on
plot(t(locs), pks, 'yo', 'MarkerSize', 8, 'LineWidth', 2)
title("ECG with R-Peak Detection")
xlabel("Time (s)"); ylabel("Amplitude")
grid on
hold off

% ============================================================
% SEND ECG TO SIMULINK — RC6 FIX: Use proper timeseries object
% ============================================================
combined_ecg = combined_ecg(:);              % column vector (required by timeseries)
t_col        = (0:length(combined_ecg)-1)' / fs;

% FIXED — send already-filtered ECG
filtered_col = filtered(:);              % column vector
t_col = (0:length(filtered_col)-1)' / fs;
ecg_ts = timeseries(filtered_col, t_col);
ecg_ts.Name = 'ECG_Signal';
assignin('base', 'ecg_ts', ecg_ts);

% Print simulation stop time so you can set it correctly in Simulink
fprintf("\nSimulink stop time should be set to: %.4f seconds\n", t_col(end))
fprintf("Simulink step size must be: %.6f seconds (= 1/125)\n", 1/fs)
disp("Run the MATLAB script BEFORE pressing Play in Simulink.")
disp("Both ecg_ts and ECG_max_amp are now in the base workspace.")
set_param(bdroot, 'SimulationCommand', 'stop');