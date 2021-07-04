function [ ] = PieChart( Img )
cArr = GetSlices(Img);
prcnt = calcPercent(cArr);
MatchSlicesWithRatios( prcnt,cArr,Img );
end


function cArr = GetSlices (Img)
ICopy=Img;
ICopy=rgb2gray(ICopy);
ICopy=imbinarize(ICopy);
figure, imshow(ICopy);

% Remove White Spaces between Slices
mask=strel('disk',5);
ICopy=imerode(ICopy,mask);
ICopy=imdilate(ICopy,mask);

[c,r]=imfindcircles(ICopy,[90,190],'ObjectPolarity','dark','sensitivity',0.9)
ISize=size(ICopy);
figure, imshow(ICopy);

% Extract Colored Circle
ci=[c(2),c(1),r];
[xx,yy]=ndgrid((1:ISize(1))-ci(1),(1:ISize(2))-ci(2));
mask=(xx.^2+yy.^2)<ci(3)^2;
CImg=uint8(zeros(size(Img)));
CImg(:,:,1)=Img(:,:,1).*uint8(mask);
CImg(:,:,2)=Img(:,:,2).*uint8(mask);
CImg(:,:,3)=Img(:,:,3).*uint8(mask);

gImg = rgb2gray(CImg);
figure, imshow(gImg)

% Separate Slices
edged = edge(gImg, 'Canny');
figure, imshow(edged)
mask=strel('disk',5);
dilated=imdilate(edged,mask);
figure, imshow(dilated)
for i=1:size(gImg,1)
    for j=1:size(gImg,2)
        if dilated(i,j) ~= 0
            gImg(i,j) = 0;
        end
    end
end
figure, imshow(gImg)

CC = bwconncomp(gImg);
L = labelmatrix(CC)

cArr = { };
bwCntr = [];
prcnt = [];

for objectidx = 1:CC.NumObjects
    cSlice = CImg .* uint8((L == objectidx));
%     bwSlice = gImg .* uint8((L == objectidx));
    cArr{objectidx} = cSlice;
end

end


function [ ] = MatchSlicesWithRatios( prcnt,cArr,myImg )

legs_orig = LegendDetector(myImg);
legs = legs_orig;

for x =1:size(legs,2)
    legs{x} = detectSquare(legs_orig{x});
end
for x = 1:size(legs,2)
    try
        legs{x} = legs{x}(5:(size(legs{x},1)-5),1:10,:);
    catch
    end
    legs{x} = imrotate(legs{x},90);
end
passColor = {};
passColor{end+1} = [0,0,0];
sliceIndex = 1;
Matched = false;
while sliceIndex <= size(cArr,2)
    %   COLOR EXTRACTOR
    color = ExtractColor(cArr{sliceIndex},passColor);
    for legIndex = 1:size(legs,2)
        %   MATCH LEGEND
        Matched = MatchLegend(legs{legIndex},color);
        if Matched == true
            figure, imshow(legs_orig{legIndex}),title(prcnt(sliceIndex))
            break
        end
    end
    if Matched == false
        passColor{end+1} = color;
    else
        cArr{sliceIndex} = [];
        sliceIndex = sliceIndex + 1;
        passColor = {};
        passColor{end+1} = [0,0,0];
    end
end

end


function Mapped = MatchLegend( leg,color )
Mapped = false;
for i = 1:size(leg,1)
    for j = 1:size(leg,2)
        if leg(i,j,1) == color(1) && leg(i,j,2) == color(2) && leg(i,j,3) == color(3)
            Mapped = true;
            break
        end
    end
    if Mapped == true
        break
    end
end
end


function mySquare = detectSquare( leg )

w = floor(size(leg,2)/12);
mySquare = leg(1:size(leg,1),10:w*5,:);
cntr = 1;
mybool = true;

for i = 1:size(mySquare,2)
    for j = 1:size(mySquare,1)
        if (mySquare(j,i,1) > 250 && mySquare(j,i,2) > 250 && mySquare(j,i,3) > 250) || (mySquare(j,i,1) < 10 && mySquare(j,i,2) < 10 && mySquare(j,i,3) < 10)
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

cntr = 1;
mybool = true;
for j = 1:size(mySquare,1)
    for i = 1:size(mySquare,2)
        if (mySquare(j,i,1) > 250 && mySquare(j,i,2) > 250 && mySquare(j,i,3) > 250) || (mySquare(j,i,1) < 10 && mySquare(j,i,2) < 10 && mySquare(j,i,3) < 10)
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
mySquare = mySquare(cntr:size(mySquare,1),1:size(mySquare,2),:);

end


function prcnt = calcPercent( slices )

prcnt = zeros(size(slices));
cntr = zeros(size(slices));

for x = 1:size(slices,2)
    cSlice = slices{x};
    for i = 1:size(cSlice,1)
        for j = 1:size(cSlice,2)
            if cSlice(i,j,1) ~= 0 || cSlice(i,j,2) ~= 0 || cSlice(i,j,3) ~= 0
                cntr(x) = cntr(x) + 1;
            end
        end
    end
end
for i = 1:size(slices,2)
    prcnt(i) = cntr(i)/sum(cntr)*100;
end

end


function legends = LegendDetector( img )
I=img;
Z=I;
[h, w, c] = size(I);

text='pie';
bw=im2bw(I,0.1);
bw=~bw;
a = bwareafilt(bw,1);
s = strel('square',10);
B=imdilate(a,s);
[L, num] = bwlabel(B);
RGB = label2rgb(L);
[h, w, ~] = size(Z);
for i=num
    x = uint8(L==i);
    f = sum(sum(x==1));
    d = zeros(size(Z));
    d(:,:,1) = uint8(x).*Z(:,:,1);
    d(:,:,2) = uint8(x).*Z(:,:,2);
    d(:,:,3) = uint8(x).*Z(:,:,3);
end
region=regionprops(L,'BoundingBox');
r=region(1).BoundingBox;
final=imcrop(Z,[r(1),r(2),r(3),r(4)]);

bw=rgb2gray(final);
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
bb=im2bw(x,0.9);
bb=~bb;
o=a*b;
if o<9999
    s = strel('square',4);
    q=imdilate(bb,s);
    s = strel('line',6,0);
    q=imdilate(q,s);
elseif o>34410 && a>b
    s = strel('square',7);
    q=imdilate(bb,s);
    s = strel('line',30,0);
    q=imdilate(q,s);
else
    s = strel('square',7);
    q=imdilate(bb,s);
    s = strel('line',14,0);
    q=imdilate(q,s);
end

[L, num] = bwlabel(q);
RGB = label2rgb(L);
[h, w, ~] = size(final);
legends=[];

region=regionprops(L,'BoundingBox');
for i=1:num
    r=region(i).BoundingBox;
    no=imcrop(final,[r(1),r(2),r(3),r(4)]);
    legends{i}=no;
end
end
