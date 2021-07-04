function str = IdentifyObjects( Img )
str = '';
Img = rgb2gray(Img);
Img = medfilt2(Img);
figure,imshow(Img);

Img = edge(Img,'canny');
figure, imshow(Img);


se=strel('square',10);
Img= imdilate(Img,se);
figure, imshow(Img);
Img = imfill(Img,'holes');
figure, imshow(Img);

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
    
    figure,imshow(L);
end
figure,imshow(f);
[rows columns] = size(f);
ctr = sum(f(:) == 1);
ctr
if ctr > 1000
    str = 'Pie';
else
    str = 'Bar';
end
str
end