# OtsuSegmentation
An algorithm to highlight the different regions in an image using an extended version of Otsu's statistical thresholding. The different regions in an image are grouped into a greyscale value, depending on how many regions were found, the output shows the number of regions and corresponding greyscale value of each region.

### Explanation
The underlying logic is to create a histogram of the greyscale values in the image and find threshold(s) in this histogram that splits the image into some groups and minimizes the weighted sum of within group variances.

![image](https://user-images.githubusercontent.com/96152967/229216223-3687d8a9-11d0-409c-b23c-56668815ab02.png)

## Dependencies

1. MATLAB Parallel Processing Toolbox, depeding on your systems bounds the default profile for the parallel pool can be 'Threads' or 'Processes'
2. Image Processing Toolbox for 'imwrite' and 'imread'

## Usage

1. To run the program, add folder containing “Segmentation_code.m” and the image files into the MATLAB path.
2. Run the program in MATLAB
3. Enter the input image name in the MATLAB command line, no need to add the “.bmp”
4. The command line will output number of regions, and thresholds found
5. Wait for the script to display all the relevant graphs and image outputs in order
6. If the name of the file was entered incorrectly, re-run the program

## Example outputs

Original image:

![image](https://user-images.githubusercontent.com/96152967/216785254-cd03b5e3-be7d-4755-8a38-92ddcdbe874e.png)

Segmented image:

![image](https://user-images.githubusercontent.com/96152967/216785237-d6d74f9a-d3db-4a6b-9e59-42e545fd6657.png)

Original image: 

![image](https://user-images.githubusercontent.com/96152967/216785159-2111ccb3-9a75-41b1-823b-5113683393af.png)

Segmented image:

![image](https://user-images.githubusercontent.com/96152967/216785203-f8653ddd-fbd9-4a18-8aef-2edc85c10bde.png)

Original image:

![image](https://user-images.githubusercontent.com/96152967/216785306-221c2f94-77dd-4cdb-84eb-fe26f67e42a0.png)

Segmented image:

![image](https://user-images.githubusercontent.com/96152967/216785333-677f7a95-32b5-4263-a03b-2d7e96568342.png)




