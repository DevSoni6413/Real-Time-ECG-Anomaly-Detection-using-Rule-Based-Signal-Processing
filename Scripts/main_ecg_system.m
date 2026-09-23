t = linspace(0,5,5000); % time signal
%generate signal
a = generate_signal(t); 

% noise signal containing mix of clean and noise signal
mixed = noise_signal(a);

% filtering signal
filtered = filtered_signal(mixed);

%peak detection
[pks, locs] = peak_detection(filtered);
% normal R vs abnormal R
normal = pks <2.5;
abnormal = pks>2.5;
if pks < 2.5
    disp("Peak is normal")
else
    disp("Peak is abnormal")
end

peak_gaps = diff(locs)
fs = 1000;
RR = diff(locs)/fs
BPM = 60/mean(RR);
disp('BPM is')
disp(BPM)

if BPM > 100
    disp("Tachycardia is detected")
elseif BPM < 55
    disp("Bradycardia is detected")
else
    disp("Heartbeat is normal")
end

if max(abs(filtered))<0.1
    disp("Sensor disconnected !!")
end

% checking consistency of heartbeat
variation = std(RR);
disp('variation is')
disp(variation)

if variation < 0.1
    disp('Regular rhythm')
else
    disp('Irregular rhythm')
end

if BPM>110 && variation > 0.1
    disp("Repeated premature beats detected")
end

%threshold based detection
anomaly = threshold_detection(filtered);

subplot(5,1,1)
plot(t, a, 'r-')
title("CLEAN SIGNAL")
xlabel("time")
ylabel("Amplitude")
subplot(5,1,2)
plot(t, mixed, 'y-')
title("MIXED SIGNAL")
xlabel("time")
ylabel("Amplitude")
subplot(5,1,3)
plot(t, filtered, 'g-')
title("FILTERED SIGNAL")
xlabel("time")
ylabel("Amplitude")
subplot(5,1,4)
plot(t, filtered, 'b-')
hold on
plot(t(locs(normal)), pks(normal), 'ro')
plot(t(locs(abnormal)), pks(abnormal), 'yo')
title("FILT.. SIGNAL WITH PEAK DETECTION")
xlabel("time")
ylabel("Amplitude")
subplot(5,1,5)
plot(t, filtered, 'w-')
hold on
plot(t(anomaly), filtered(anomaly), 'bo')
title("FILT.. SIGNAL WITH THRESHOLD BASED DETECTION")
grid on
hold off
