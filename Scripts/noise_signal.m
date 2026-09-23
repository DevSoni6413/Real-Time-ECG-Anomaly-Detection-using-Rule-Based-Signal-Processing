function mixed = noise_signal(a)
    noise = 0.5*randn(size(a));
    mixed = a + noise;
end
