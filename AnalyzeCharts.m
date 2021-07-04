function [ ] = AnalyzeCharts( Img )
figure, imshow(Img)
ChartType = IdentifyObjects(Img);
if ChartType == 'Bar'
    BarChart(Img);
elseif ChartType == 'Pie'
    PieChart(Img);
end
fprintf('Done');
end



function str = IdentifyObjects( Img )
str = '';
Img = rgb2gray(Img);
Img = medfilt2(Img);

Img = edge(Img,'canny');

se=strel('square',10);
Img= imdilate(Img,se);
Img = imfill(Img,'holes');
[L num] = bwlabel(Img);
x = regionprops(L,'Perimeter', 'Area');
circularities = [x.Perimeter] .* [x.Perimeter] ./ (4 * pi * [x.Area]);
f = zeros(size(Img));
for i=1:num
    y=uint8(L==i);
    d=zeros(size(Img));
    d(:,:) = uint8(y).* uint8(Img(:,:));
    if circularities(i) <= 1.1
        f = f+d;
    end
end
[rows columns] = size(f);
ctr = sum(f(:) == 1);
if ctr > 1000
    str = 'Pie';
else
    str = 'Bar';
end
end