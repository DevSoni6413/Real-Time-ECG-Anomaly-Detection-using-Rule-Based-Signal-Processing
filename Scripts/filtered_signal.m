function filtered = filtered_signal(mixed)
    fs = 1000;
    filtered = lowpass(mixed, 30, fs);
end
