function [pks,locs] = peak_detection(filtered)
    [pks,locs] = findpeaks(filtered, 'MinPeakHeight', 0.9, 'MinPeakDistance', 500, 'MinPeakProminence', 0.5);
end
