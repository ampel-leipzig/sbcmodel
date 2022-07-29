function [ppv] = calc_ppv(sens, spec, prev)
ppv = (sens.*prev) ./ (sens.*prev + ((1-spec) .* (1-prev))) ;
end

