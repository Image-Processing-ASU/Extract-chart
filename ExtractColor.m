function color = ExtractColor( Bar , passColor )
color = [-1,-1,-1];
colorFound = false;
for i = 1:size(Bar,1)
    for j = 1:size(Bar,2)
        passPxl = false;
        for x = 1:size(passColor,2)
            if Bar(i,j,1) == passColor{x}(1) && Bar(i,j,2) == passColor{x}(2) && Bar(i,j,3) == passColor{x}(3)
                passPxl = true;
                break;
            end
        end
        if passPxl == true
            continue
        else
            color(1) = Bar(i,j,1);
            color(2) = Bar(i,j,2);
            color(3) = Bar(i,j,3);
            colorFound = true;
            break;
        end
    end
    if colorFound == true
        break
    end
end
end