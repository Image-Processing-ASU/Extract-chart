% PIE TEST CASES
img1 = 'D:\Study\Test Cases\Case 3\1.png';
img2 = 'D:\Study\Test Cases\Case 3\2.jpg';
img3 = 'D:\Study\Test Cases\Case 1\1.png';
img4 = 'D:\Study\Test Cases\Case 1\2.jpg';
% BAR TEST CASES
img5 = 'D:\Study\Test Cases\Case 2\1.png';
img6 = 'D:\Study\Test Cases\Case 2\2.jpg';
img7 = 'D:\Study\Test Cases\Case 4\1.jpg';
img8 = 'D:\Study\Test Cases\Case 4\2.png';
bonus8 = 'D:\Study\Test Cases\Bonuses\Case 8\1.JPG';

clc;
close all

%   WHOLE PROJECT
Img = imread(img3);
AnalyzeCharts(Img);


%   PIE CHART TEST
% myImg = img2;
% Img=imread(myImg);
% figure, imshow(Img)
% PieChart(Img)


%   BAR CHART TEST
% myImg = bonus8;
% Img=imread(myImg);
% figure, imshow(Img);
% BarChart(Img)

% [bars,nums,per] = getBars( Img );
% legs = BarLegendDetector(Img);
% 
% for i = 1:size(bars,2)
%     figure, imshow(bars{i}), title('Bar');
% end
% 
% MapRatios2(per, bars, Img);
