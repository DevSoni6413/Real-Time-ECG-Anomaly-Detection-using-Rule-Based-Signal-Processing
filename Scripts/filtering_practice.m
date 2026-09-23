t = linspace(0,1,1000); % time vector
a = 2*sin(2*pi*4*t); % clean signal
noise = 0.5*randn(size(t)); % noise signal
mixed = a + noise; % mixed signal
subplot(5,1,1)
plot(t,a,'r-')
title("CLEAN SIGNAL")
xlabel("time")
ylabel("Amplitude")
subplot(5,1,2)
plot(t,noise,'y-')
title("NOISE SIGNAL")
xlabel("time")
ylabel("Amplitude")
subplot(5,1,3)
plot(t,mixed,'g-')
title("MIXED SIGNAL")
xlabel("time")
ylabel("Amplitude")
filtered = movmean(mixed,25);
subplot(5,1,4)
plot(t,filtered,'b-')
title("FILTERED SIGNAL WITH PEAK DETECTION")
xlabel("time")
ylabel("Amplitude")
hold on
%peak-based detection
[pks, locs] = findpeaks(filtered, 'MinPeakHeight', 1.5, 'MinPeakDistance', 100);
plot(t(locs), pks,'ro')
grid on
%threshold based detection
anomaly = filtered > 1.5
subplot(5,1,5)
plot(t(anomaly), filtered(anomaly), 'co')
title("THRESHOLD - BASED DETECTION")
xlabel("time")
ylabel("Amplitude")
grid on