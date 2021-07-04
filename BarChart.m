function [ ] = BarChart( Img )

[bars,~,per] = getBars( Img );
legs = BarLegendDetector(Img);
MatchBarsWithRatios(per, bars, legs); % Match legends with percentages

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [barCrops,numOfBars,percentages]=getBars(img)
%%%%Removing black values from image%%%%
OGimg=img;
img(img==0)=255;
imgBW = rgb2gray(img);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%Applying edge detection to find each bar%%%%
imgBW = edge(imgBW,'canny',0.075);
se = strel('square', 5);
imgBW = imdilate(imgBW,se);
imgBW = ~imgBW;
[elements, numOfElements] = bwlabel(imgBW);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%Filtering larger and smaller objects%%%%
[h, w, ~] = size(img);
smallRatio = h*w*0.006;
largeRatio = h*w*0.25;
d = zeros(size(imgBW));
for i=1:numOfElements
    imgBW = uint8(elements==i);
    res=sum(imgBW==1);
    f = sum(sum(imgBW==1));
    if f < smallRatio
        continue;
    end
    if f >= largeRatio
        continue;
    end
    d(elements==i)=255;
    %figure, imshow(d);
end
d=imfill(d,'holes');
[bars, numOfBars]=bwlabel(d);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%Finding the bars by finding the rectangles with similar width%%%%
stats=regionprops(bars,'BoundingBox');
boxes=[stats.BoundingBox];
sortedBoxes=[];
for i=1:length(boxes)/4
    sortedBoxes(i,1)=i;
    sortedBoxes(i,2)=boxes((i*4)-1);
end
sortedBoxes=sortrows(sortedBoxes,2,'descend');
for i=1:size(sortedBoxes,1)
    if i==size(sortedBoxes,1)
        if sortedBoxes(i-1,2)-sortedBoxes(i,2)>=10
            sortedBoxes(i,1)=0;
        end
    else
        if sortedBoxes(i,2)-sortedBoxes(i+1,2)>=10
            if i==1
                sortedBoxes(i,1)=0;
            else
                if sortedBoxes(i-1,1)~=0
                    continue;
                else
                    sortedBoxes(i,1)=0;
                end
            end
        end
    end
end
sortedBoxes(sortedBoxes==0,:)=[];
fin=zeros(h,w);
indexes=sortedBoxes(:,1);
for x=1:length(indexes)
    fin(bars==indexes(x))=255;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%using 'bwlabel' to find each bar%%%%
[bars, numOfBars]=bwlabel(fin);
stats=regionprops(bars,'BoundingBox');
boxes=[stats.BoundingBox];
barCrops=[];
for i=1:numOfBars
    barCrops{i}=imcrop(OGimg,[stats(i).BoundingBox(1),stats(i).BoundingBox(2),stats(i).BoundingBox(3),stats(i).BoundingBox(4)]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%cropping out the y-axis%%%%
crp = imcrop(OGimg,[0,0,boxes(1)-5,w]);
crp=edge(rgb2gray(crp),'canny',0.075);
crp=imdilate(crp,strel('disk',3));
[numbers,num]=bwlabel(crp);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%Finding the highest and lowest points of the y-axis%%%%
numberStats=regionprops(numbers,'BoundingBox');
heights=[numberStats.BoundingBox];
sortedHeights=[];
for i=1:length(heights)/4
    sortedHeights(i,1)=numberStats(i).BoundingBox(2);
    sortedHeights(i,2)=numberStats(i).BoundingBox(4);
end
sortedHeights=sortrows(sortedHeights,1);
percentages=[];
highestPoint=sortedHeights(1,1)+8; %adding a margin to compensate for inflation caused by 'imdilate'
lowestPoint=stats(1).BoundingBox(2)+stats(1).BoundingBox(4)-7; %removing a margin to compensate for inflation caused by 'imdilate'
height=lowestPoint-highestPoint;
for i=1:numOfBars
    percentages(i)=((stats(i).BoundingBox(4))/(height))*100;
    if percentages(i)>100
        percentages(i)=100;
    end
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function list = BarLegendDetector( I )
Z=I;
[h, w, c] = size(I);
d=fix(w/8);
I(:,(6.*d)+1:end,:)=0;
I=Z-I;
A=Z;
d=fix(h/8);
Z(1:((1.6).*d)+1,:)=0;
Z=A-Z;
bw1=im2bw(I,0.48);
bw2=im2bw(Z,0.48);
s = strel('square',3);
bw1=~bw1;
bw2=~bw2;
bw1=imdilate(bw1,s);
bw2=imdilate(bw2,s);
a = bwareafilt(bw1,2);
a1 = bwareafilt(bw2,2);
[L, num] = bwlabel(a);
[W,N]=bwlabel(a1);
re=regionprops(W,'BoundingBox','Area');
region=regionprops(L,'BoundingBox','Area');
rr=re(2).Area;
r=region(2).Area;
ra=region(2).BoundingBox;
ro=re(2).BoundingBox;
final=imcrop(A,[ra(1),ra(2),ra(3),ra(4)]);
[p,q,t]=size(final);
t=p*q;
%754,5016
final1=imcrop(A,[ro(1),ro(2),ro(3),ro(4)]);
if rr>r && t<1000
    final=final1;
end
% figure,imshow(final);

bw=im2bw(final,0.5);
bw=~bw;
s = strel('square',1);
B=imerode(bw,s);
B=imfill(B,'holes');
ctr = sum(B(:) == 1);
if ctr< 3000
    B=imfill(B,'holes');
    s = strel('square',1);
    B=imdilate(bw,s);
    B=~B;
else
    B=imfill(B,'holes');
    B=~B;
    s = strel('square',1);
    B=imdilate(bw,s);
    B=~B;
end
[h,w]=size(B);
[a,b,c]=size(final);
x=final;
for i=1:a
    for j=1:b
        if B(i,j)==0
            x(i,j,:)=255;
        end
    end
end
%6080-4.1, 32736-3.2, 34404-1.2, 11832-1.1, 34602-3.1, 45225-4.2,
%27560-2.2, 41255-2.1
bb=im2bw(x,0.9);
bb=~bb;
% figure,imshow(bb),title('d');
o=a*b;
if o<9999
    s = strel('square',6);
    q=imdilate(bb,s);
    s = strel('line',29,0);
    q=imdilate(q,s);
elseif o>9999 && o<30000
    s = strel('square',9);
    q=imdilate(bb,s);
    s = strel('line',14,0);
    q=imdilate(q,s);
elseif o>34410 && a>b
    s = strel('square',15);
    q=imdilate(bb,s);
    s = strel('line',65,0);
    q=imdilate(q,s);
else
    s = strel('diamond',9);
    q=imdilate(bb,s);
    s = strel('line',7,0);
    q=imdilate(q,s);
    
    s = strel('line',3,135);
    q=imdilate(q,s);
    s = strel('line',3,90);
    q=imerode(q,s);
end
%  figure,imshow(q),title('black');

[L, num] = bwlabel(q);
RGB = label2rgb(L);
[h, w, ~] = size(final);
list=[];

region=regionprops(L,'BoundingBox');
for i=1:num
    r=region(i).BoundingBox;
    no=imcrop(final,[r(1),r(2),r(3),r(4)]);
    list{i}=no;
    % figure,imshow(list{i}),title(i);
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ ] = MatchBarsWithRatios( Percentages,Bars,Legends )
legs = Legends;
legs = CropLegends(legs); % Clean legends for processing

passColor = {};
passColor{end+1} = [0,0,0];
sliceIndex = 1;
Matched = false;
while sliceIndex <= size(Bars,2)
    %   COLOR EXTRACTOR
    color = ExtractColor(Bars{sliceIndex},passColor);
    for legIndex = 1:size(legs,2)
        %   MATCH LEGEND
        Matched = MatchLegend(legs{legIndex},color);
        if Matched == true
            figure, imshow(Legends{legIndex}),title(Percentages(sliceIndex))
            legs{legIndex} = [];
            break
        end
    end
    if Matched == false  % Re-iterate with different pixel sample from legend
        passColor{end+1} = color;
    else
        Bars{sliceIndex} = [];
        sliceIndex = sliceIndex + 1;
        passColor = {};
        passColor{end+1} = [0,0,0];
    end
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Cropped = CropLegends( legs )
for i = 1:size(legs,2)
    legs{i} = legs{i}(1:size(legs{i},1),1:fix(size(legs{i},2)/3)-2,:); % Decrease width
    legs{i} = OptimizeLegend(legs{i},true);
    legs{i} = imrotate(legs{i},180);
    legs{i} = OptimizeLegend(legs{i},true);
    legs{i} = imrotate(legs{i},90);
end
Cropped = legs;
end

function optimized = OptimizeLegend( leg,recurse )
mySquare = leg;

%   Horizontal Resize
%   if all pixels are black or white then cut
cntr = 1;
mybool = true;
for i = 1:size(mySquare,2)
    for j = 1:size(mySquare,1)
        if (mySquare(j,i,1) == 0 && mySquare(j,i,2) == 0 && mySquare(j,i,3) == 0) || (mySquare(j,i,1) > 230 && mySquare(j,i,2) > 230 && mySquare(j,i,3) > 230) || (mySquare(j,i,1) > 100 && mySquare(j,i,1) < 120 && mySquare(j,i,2) > 100 && mySquare(j,i,2) < 120 && mySquare(j,i,3) > 100 && mySquare(j,i,3) < 120)
            continue;
        else
            mybool = false;
            break;
        end
    end
    if mybool == true
        cntr = cntr+1;
    else
        break;
    end
end
mySquare = mySquare(1:size(mySquare,1),cntr:size(mySquare,2),:);
if recurse == true %   Vertical Resize
    mySquare = imrotate(mySquare, -90);
    optimized = OptimizeLegend(mySquare,false);
else
    optimized = imrotate(mySquare,90);
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Mapped = MatchLegend( leg,color )
Mapped = false;
%   Upper & Lower limits for pixels of RGB
redUp = 1;
redDown = 0;
blueUp = 1;
blueDown = 0;
greenUp = 20;
greenDown = 20;

for i = 1:size(leg,1)
    for j = 1:size(leg,2)
        if leg(i,j,1) == color(1) && leg(i,j,2) == color(2) && leg(i,j,3) == color(3)
            Mapped = true;
            break
        elseif (leg(i,j,1) >= color(1)-redDown && leg(i,j,1) < color(1)+redUp) && (leg(i,j,2) >= color(2)-greenDown && leg(i,j,2) < color(2)+greenUp) && (leg(i,j,3) >= color(3)-blueDown&& leg(i,j,3) < color(3)+blueUp)
            Mapped = true;
            break
        end
    end
    if Mapped == true
        break
    end
end
end
