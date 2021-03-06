
function rgb_dkl_isolum = correct_illuminance(rgb_dkl_orig,monitor,post_gc,plot_figs)
% rgb_dkl_isolum = correct_illuminance(rgb_dkl_orig,monitor,post_gc,plot_figs)
%
%   Applies gamma model-based isoluminance correction to a set of colors
%   Designed to be applied to a RGB coordinates drawn from DKL space, but will
%   work for any set of RGB colors.
%
%   Illuminance correction is designed to preserve hue, by modifying the
%   RGB value of each phosphor according to its individual gamma function
%
%   input arg post_gc can be set to 1 if correction should be done assuming
%   automatic gamma correction (e.g. within Psychtoolbox, or in software of
%   HMRC BOLDscreen). 
%
%   author: Nicholas Blauch
%
%   notes:
%   2/20/18 nmb wrote it
%   5/18: nmb: n_iters set to 1 if check_spline_model=0. this is only for
%   clarity, and does not change the results.
%   6/20: nmb: MAKE NOTE: HMRC no longer performs in-house gamma
%   correction. set post_gc=0. added some commenting for clarity. 

load(['gammaFit-',monitor])

check_spline_model = 0; % could set to 1 if you trust the spline model over the gamma model
if check_spline_model
    n_iters = 4; 
else
    n_iters = 1; %all the correction takes place in first iteration due to the application of an analytical solution
end

if ~post_gc
    for iter = 1:n_iters
        if iter > 1
            rgb_dkl = rgb_dkl_isolum;
        else
            rgb_dkl = rgb_dkl_orig;
        end
        if check_spline_model
            Vin = uint8(255*(rgb_dkl));
            Vout = zeros(size(Vin));
            for chan = 1:3
                for ii = 1:size(Vin,1)
                    Vout(ii,chan) = displaySplineModel(Vin(ii,chan)+1,chan);
                end
            end
        else
            Vin = rgb_dkl;
            Vout = zeros(size(Vin));
            for chan = 1:3
                Vout(:,chan) = (Vin(:,chan).^(displayGamma(chan)))*(displayConstant(chan));
            end
        end
        
        Vout_sum = sum(Vout,2);
        if (iter == 1) && plot_figs
            figure; plot(Vout_sum)
            title('Pre-correction')
            ylabel('Predicted Illuminance (lux)')
            xlabel('Color')
        end
        
        h = min(Vout_sum(:))./Vout_sum; %scalar scaling factor
        %scaling factor must be taken to the 1/gamma for proper correction
        %since we computed a per-phosphor gamma model, we correct with it
        h_gamma = zeros(size(Vin));
        for chan = 1:3
            h_gamma(:,chan) = h.^(1/displayGamma(chan)); %channel-specific scaling factors
        end
        rgb_dkl_isolum = (rgb_dkl).*(h_gamma); %apply correction
        
        %now determine Vout for corrected colors
        if check_spline_model
            Vin = 255.*rgb_dkl_isolum;
            Vout = zeros(size(Vin));
            for chan = 1:3
                for ii = 1:size(Vin,1)
                    Vout(ii,chan) = displaySplineModel(uint8(Vin(ii,chan))+1,chan);
                end
            end
        else
            Vin = rgb_dkl_isolum;
            Vout = zeros(size(Vin));
            for chan = 1:3
                Vout(:,chan) = (Vin(:,chan).^(displayGamma(chan)))*(displayConstant(chan));
            end
        end
        
        Vout_sum = sum(Vout,2);
        
        if (iter == n_iters) && plot_figs
            figure; plot(Vout_sum)
            title('Post-correction')
            ylabel('Predicted Illuminance (lux)')
            xlabel('Color')
        end
        
    end
        
else %if do post_gc (e.g. on BOLDscreen)
    for iter = 1:n_iters
        if iter > 1
            rgb_dkl = rgb_dkl_isolum;
        end
        
        Vin = rgb_dkl;
        Vout = zeros(size(Vin));
        for chan = 1:3
            Vout(:,chan) = Vin(:,chan)*(displayConstant(chan));
        end
        
        Vout_sum = sum(Vout,2);
        if (iter == 1) && plot_figs
            figure; plot(Vout_sum)
            title('Pre-correction')
            ylabel('Predicted Illuminance (lux)')
            xlabel('Color')
        end
        h = min(Vout_sum(:))./Vout_sum;
        
        h_gamma = zeros(size(Vin));
        for chan = 1:3
            h_gamma(:,chan) = h;
        end
        rgb_dkl_isolum = (rgb_dkl).*(h_gamma);
        
        Vin = rgb_dkl_isolum;
        Vout = zeros(size(Vin));
        for chan = 1:3
            Vout(:,chan) = Vin(:,chan)*(displayConstant(chan));
        end
        Vout_sum = sum(Vout,2);
        if (iter == n_iters) && plot_figs
            figure; plot(Vout_sum)
            title('Post-correction')
            ylabel('Predicted Illuminance (lux)')
            xlabel('Color')
        end
        
    end
end
