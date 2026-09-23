rng(1)
t = linspace(0,5,5000); % time signal
%generate signal
a = generate_signal(t); 

% noise signal containing mix of clean and noise signal
mixed = noise_signal(a);
%sampling freq
fs = 1000;

% filtering signal with movmean filter
filtered1 = movmean(mixed, 25);

%filtering signal with lowpass filter
filtered2 = lowpass(mixed, 30, 1000);

%peak detection for both filters
[pks1, locs1] = peak_detection(filtered1);
[pks2, locs2] = peak_detection(filtered2);

disp("peaks with movmean filter")
length(locs1)
disp("peaks with lowpass filter")
length(locs2)

%RR peak interval and BPM
RR1 = diff(locs1)/fs;
RR2 = diff(locs2)/fs;
BPM1 = 60/mean(RR1);
BPM2 = 60/mean(RR2);
disp("RR interval with movmean")
disp(RR1)
disp("RR interval with lowpass")
disp(RR2)
disp("BPM with movmean")
disp(BPM1)
disp("BPM with lowpass")
disp(BPM2)

%plotting
subplot(3,1,1)
plot(t, mixed,'c')
title(" MIXED SIGNAL ")
xlabel("time")
ylabel("Amplitude")
grid on

subplot(3,1,2)
plot(t, filtered1, 'r')
hold on
plot(t(locs1),pks1,'go')
title(" FILTERED WITH MOVMEAN FILTER")
xlabel("time")
ylabel("Amplitude")
grid on
hold off
subplot(3,1,3)
plot(t, filtered2)
hold on
plot(t(locs2),pks2,'go')
title(" FILTERED WITH LOWPASS FILTER")
xlabel("time")
ylabel("Amplitude")
grid on