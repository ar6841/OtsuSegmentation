function [S,t1_min,t2_min]=par_double_threshold(H,N)

% Thresholding functions take Histogram and number of pixels as imput
% S is the minimum weighted sum of variance found and t is the threshold(s) 
% of the image
% Divide the histogram using 1-3 thresholds and output minimum
% variance found in each case

%% Initialize variables
    S_vec = zeros(255);
    S_vec(:,:) = inf;

    parfor t1=1:254
        % Second threshold starts from t1+1
        for t2=2:255
        % If no pixels are present between thresholds, iterate t
            if(sum(H(1:t1+1))>0 && sum(H(t1+2:t2+1))>0 && sum(H(t2+2:256))>0)

                % Calculate Weights
                Wa = 1/N*sum(H(1:t1+1));
                Wb = 1/N*sum(H(t1+2:t2+1));
                Wc = 1/N*sum(H(t2+2:256));

                % Calculate Mean of regions
                % Element wise product of vectors
                Ua = sum((0:t1).*H(1:t1+1))/sum(H(1:t1+1));
                Ub = sum((t1+1:t2).*H(t1+2:t2+1))/sum(H(t1+2:t2+1));
                Uc = sum((t2+1:255).*H(t2+2:256))/sum(H(t2+2:256));

                % Calculate Variance of regions
                % Element wise product of vectors
                Sa = (sum((((0:t1)-Ua).^2).*H(1:t1+1)))/(sum(H(1:t1+1)));
                Sb = (sum((((t1+1:t2)-Ub).^2).*H(t1+2:t2+1)))/(sum(H(t1+2:t2+1)));
                Sc = (sum((((t2+1:255)-Uc).^2).*H(t2+2:256)))/(sum(H(t2+2:256)));

                % Calculate weighted sum of within group variances
                S_vec(t1,t2) = Wa*Sa+Wb*Sb+Wc*Sc;

                % Check if current variance is the least value found
            end
        end
    end

    [S,pos] = min(S_vec(:));
    [t1_min,t2_min] = ind2sub(size(S_vec), pos);

end