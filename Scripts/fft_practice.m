t = linspace(0,5,5000); % time signal
%generate signal
a = generate_signal(t); 

% noise signal containing mix of clean and noise signal
mixed = noise_signal(a);

% filtering signal
filtered = filtered_signal(mixed);

%sampling frequency
fs = 1000;

Y1 = fft(mixed);
Y2 = fft(filtered);

%frequency axis
f = (0:length(Y1)-1)*(fs/length(Y1));

subplot(2,1,1)
plot(f,abs(Y1),'r')
title("FFT OF NOISY ECG")
xlabel("frequency")
ylabel("amplitude")
xlim([0 50])
grid on

subplot(2,1,2)
plot(f, abs(Y2))
title("FFT OF FILTERED ECG")
xlabel("frequency")
ylabel("amplitude")
xlim([0 50])
grid on