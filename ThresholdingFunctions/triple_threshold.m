function [S,t1_min,t2_min,t3_min]=triple_threshold(H,N)

%% Thresholding functions
% Thresholding functions take Histogram and number of pixels as imput
% S is the minimum weighted sum of variance found and t is the threshold(s) 
% of the image
% Divide the histogram using 1-3 thresholds and output minimum
% variance found in each case

%% Triple threshold

    S_prev = inf;
    t1_min = 0;
    t2_min = 0;
    t3_min = 0;
    for t1=0:252
        % Second threshold starts from t1+1
        for t2=t1+1:253
            % Third threshold starts from t2+1
            for t3=t2+1:254
                % If no pixels are present between thresholds, iterate t
                if(sum(H(1:t1+1))>0 && sum(H(t1+2:t2+1))>0 && sum(H(t2+2:t3+1))>0 && sum(H(t3+2:256))>0)
                    
                    % Calculate Weights
                    Wa = 1/N*sum(H(1:t1+1));
                    Wb = 1/N*sum(H(t1+2:t2+1));
                    Wc = 1/N*sum(H(t2+2:t3+1));
                    Wd = 1/N*sum(H(t3+2:256));

                    % Calculate Mean of regions
                    % Element wise product of vectors
                    Ua = sum((0:t1).*H(1:t1+1))/sum(H(1:t1+1));
                    Ub = sum((t1+1:t2).*H(t1+2:t2+1))/sum(H(t1+2:t2+1));
                    Uc = sum((t2+1:t3).*H(t2+2:t3+1))/sum(H(t2+2:t3+1));
                    Ud = sum((t3+1:255).*H(t3+2:256))/sum(H(t3+2:256));

                    % Calculate Variance of regions
                    % Element wise product of vectors
                    Sa = (sum((((0:t1)-Ua).^2).*H(1:t1+1)))/(sum(H(1:t1+1)));
                    Sb = (sum((((t1+1:t2)-Ub).^2).*H(t1+2:t2+1)))/(sum(H(t1+2:t2+1)));
                    Sc = (sum((((t2+1:t3)-Uc).^2).*H(t2+2:t3+1)))/(sum(H(t2+2:t3+1)));
                    Sd = (sum((((t3+1:255)-Ud).^2).*H(t3+2:256)))/(sum(H(t3+2:256)));

                    % Calculate weighted sum of within group variances
                    S = Wa*Sa+Wb*Sb+Wc*Sc+Wd*Sd;

                    % Check if current variance is the least value found
                    if(S<S_prev)
                        S_prev = S;
                        t1_min = t1;
                        t2_min = t2;
                        t3_min = t3;
                    else
                        S = S_prev;
                        % if current value > previous least value found
                        % reset S as previous least value found
                    end
                end
            end
        end
    end
end