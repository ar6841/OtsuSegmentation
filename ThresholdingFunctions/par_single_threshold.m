function [S,t_min]=par_single_threshold(H,N)

% Thresholding functions take Histogram and number of pixels as imput
% S is the minimum weighted sum of variance found and t is the threshold(s) 
% of the image
% Divide the histogram using 1-3 thresholds and output minimum
% variance found in each case
 
%% Initialize variables


    S_vec = zeros(255,1);

    %Loop runs from 0 to 254 as t=255 will result in one region <=t only
    parfor t=0:254
        % If no pixels are present between theshold and 0 or threshold
        % and 255, iterate t to skip those pixels

        if(sum(H(1:t+1))>0 && sum(H(t+2:256))>0)
            
            % Calculate Weights Wa and Wb
            Wa = 1/N*sum(H(1:t+1)); 
            Wb = 1/N*sum(H(t+2:256));

            % Calculate Mean of region A and B
            % Element wise product of vectors
            Ua = sum((0:t).*H(1:t+1))/sum(H(1:t+1)); 
            Ub = sum((t+1:255).*H(t+2:256))/sum(H(t+2:256));

            % Calculate Variance of region A and B
            % Element wise product of vectors 
            Sa = (sum((((0:t)-Ua).^2).*H(1:t+1)))/(sum(H(1:t+1)));
            Sb = (sum((((t+1:255)-Ub).^2).*H(t+2:256)))/(sum(H(t+2:256)));
            
            % Calculate weighted sum of within group variances
            S_vec(t+1) = Wa*Sa+Wb*Sb;
        end
    end
     [S,t] = min(S_vec);
     t_min = t-1;

end