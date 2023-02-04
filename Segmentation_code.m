close all;
%clear all;
clc;

%% Read image and determine image size
image_name = input("Enter image name, DO NOT add .bmp : ","s");
Img=imread(append(image_name,".bmp"));
tic
[n,m,~] = size(Img); 
N= n*m; %N is total number of pixels

%% Convert pixel values to greyscale and generate histogram
gray_Img = zeros(n,m);

r=0.299;
g=0.587;
b=0.114;
H=zeros(1,256); %Histogram H is a row vector, initialized as 0s for speed
for i=1:n
    for j=1:m
        gray_Img(i,j) = round(sum([r,g,b].*double([Img(i,j,1),Img(i,j,2),Img(i,j,3)])));
        
        % The pixel value of greyscale image corresponds to the index in
        % the histogram +1
        index = gray_Img(i,j)+1;
        
        % Increment the index in the histogram as a pixel value at index 
        % was found 
        H(index) = H(index) + 1;
    end
end
%% Convert original image into greyscale image and save for later
gray_Img = uint8(gray_Img);
old_gray_Img = gray_Img;

%% Thresholding functions (function definition below)

% Thresholding functions take Histogram and number of pixels as imput
% S is the minimum weighted sum of variance found and t is the threshold(s) 
% of the image
% Divide the histogram using 1-3 thresholds and output minimum
% variance found in each case

[S1,t] = single_threshold(H,N); 
[S2,t1,t2] = double_threshold(H,N);
[S3,T1,T2,T3] = triple_threshold(H,N);
% S1,S2,S3 are min variance with 1,2 and 3 thresholds respectively

%% Define output image pixel values 

background = 255; %if pixel is > than all thresholds then set this value
foreground1 = 0; %if pixel is <= than all thresholds then set this value
foreground2 = 255/3; %for pixels in between t1 and t2 (4 regions)
foreground3 = 2*255/3; %for pixels in between t2 and t3 (4 regions)
foreground_half = 255/2; % for pixels in between t1 and t2 (3 regions)

%% Decide exactly how many regions the image has
% Previous values S1-S2>200 S2-S3>150  diff=0.5 diff_2 = 0.63
diff_1 =0.43;
diff_2 =240;
% Check if variance with 1 threshold is much greater than min variance
% with 2 thresholds
if(1-S2/S1>diff_1)

% Check if variance with 2 thresholds is much greater than min variance
%  with three thresholds thresholds 

% if the difference between variances is not too much then choose 2
% thresholds
    if((1-S3/S2>diff_1) && (S2-S3>diff_2))
        % Image has 3 thresholds, record the variance and threshold values
        S = S3;
        thresholds = [T1,T2,T3];
        % Change each pixel in the grayscale image to output value
        %depending on where it lies on the histogram
        gray_Img(gray_Img(:,:)<=T1) = foreground1;
        gray_Img(gray_Img(:,:)>T1 & gray_Img(:,:)<=T2) = foreground2;
        gray_Img(gray_Img(:,:)>T2 & gray_Img(:,:)<=T3) = foreground3;
        gray_Img(gray_Img(:,:)>T3) = background;
    else
        % Image has 2 thresholds, record the variance and threshold values
        S = S2;
        thresholds = [t1,t2];
        % Set the output image values
        gray_Img(gray_Img(:,:)<=t1) = foreground1;
        gray_Img(gray_Img(:,:)>t1 & gray_Img(:,:)<=t2) = foreground_half;
        gray_Img(gray_Img(:,:)>t2) = background;

    end
else
    % Image has 1 threshold, record the variance and threshold values
    S = S1;
    thresholds = t;
     % Set the output image values
     gray_Img(gray_Img(:,:)<=t) = foreground1;
     gray_Img(gray_Img(:,:)>t) = background;

end

%% Final outputs

% Display outputs
disp(['Number of regions = ',num2str(length(thresholds)+1),]);
disp(['Threshold values = ',num2str(thresholds)]);

%Display image
gray_Img = uint8(gray_Img);
%Save image as "image name" +".bmp"
imwrite(gray_Img,append(image_name,"-out.bmp"));

%Display Output image
f1=figure;
imshow(gray_Img);
title("Grayscale image after Thresholding")

%Plot Histogram
f2=figure;
plot(H)
title("Image histogram plot")
xlabel("Grayscale value")
ylabel("Number of pixels")

%Make Vertical lines at thresholds
xline(thresholds)

% Display greyscale image BEFORE Otsus thresholding
f3=figure;
imshow(old_gray_Img);
title("Grayscale image before thresholding")
% Display original Image
f4=figure;
imshow(Img);
title("Original image")
toc

%% Thresholding functions
% Thresholding functions take Histogram and number of pixels as imput
% S is the minimum weighted sum of variance found and t is the threshold(s) 
% of the image
% Divide the histogram using 1-3 thresholds and output minimum
% variance found in each case

%% For single threshold
function [S,t_min]=single_threshold(H,N)
    %Initialize variables
    S_prev = inf;
    t_min = 0;
    %Loop runs from 0 to 254 as t=255 will result in one region <=t only
    for t=0:254
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
            S = Wa*Sa+Wb*Sb;

            % Check if current variance is the least value found
            if(S<S_prev)
                S_prev = S;
                t_min = t;
            else
                % if current value > previous least value found
                % reset S as previous least value found
                S = S_prev;
            end
        end
    end
end
function [S,t1_min,t2_min]=double_threshold(H,N)

    S_prev = inf;
    t1_min = 0;
    t2_min = 0;
    for t1=0:253
        % Second threshold starts from t1+1
        for t2=t1+1:254
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
                S = Wa*Sa+Wb*Sb+Wc*Sc;

                % Check if current variance is the least value found
                if(S<S_prev)
                    S_prev = S;
                    t1_min = t1;
                    t2_min = t2;
                else
                    % if current value > previous least value found
                    % reset S as previous least value found
                    S = S_prev;
                end
            end
        end
    end
end

function [S,t1_min,t2_min,t3_min]=triple_threshold(H,N)

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
