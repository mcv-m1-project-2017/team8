function [wcand] = SlidingWindow(mask, da, params)
    wcand = [];
    [rows, cols] = size(mask);
    vcomb = getCombinations(da, params.dims, params.ffs); %width and height combinations
    
    for c = 1:length(vcomb)
        area = vcomb(c).w * vcomb(c).h;
        disp(sprintf("Combination %d/%d",c,length(vcomb)));
        %Don't compute improvable combinations
        if(area < da('all').min_area || area > da('all').max_area)
            disp('Filtration of combination: area');
            continue;
        end
        
        for i = 1:params.jump:rows-(vcomb(c).h-1)
            for j = 1:params.jump:cols-(vcomb(c).w-1)
                coords = struct('y', i, 'x', j, 'w', vcomb(c).w, 'h', vcomb(c).h);
                
                %Calculate filling_ratio
                if(params.method == 'simple')
                    filling_ratio = FillingRatio_simple(mask, coords);
                elseif(params.method == 'sumcum')
                    ii = IntegralImage(mask);
                    filling_ratio = FillingRatio_IntegralImage(coords, ii);
                else
                    error('invalid params.method');
                end
                
                %Filling_ratio filter
                if(filling_ratio < da('all').fr_min || filling_ratio > da('all').fr_max)
                    continue;
                end
                
                disp('hey');
                wcand = [wcand; coords];
            end
        end
    end
    
    figure(1);
    imshow(double(mask))
    for i = 1:length(wcand)
        rectangle('Position',[wcand(i).x wcand(i).y wcand(i).w wcand(i).h],'EdgeColor','r','LineWidth',2 );
    end
    waitforbuttonpress();
    
end

%%% Filling ratio
% Arguments:
%   1. struct 'coords' with .x, .y, .w, .h

% 1. For loop
function [fr] = FillingRatio_simple(mask, coords)
  content_bb = mask(coords.y:coords.y+coords.h-1,coords.x:coords.x+coords.w-1);
  S = nnz(content_bb);  
  fr =  S /(coords.w*coords.h);
end

% 2. Integral Image
function [fr] = FillingRatio_IntegralImage(coords, ii)

  % Convert from x,y,w,z to 4 coordinates (x,y)
  a_coord = [coords.y+coords.h-1, coords.x+coords.w-1];
  b_coord = [coords.y, coords.x+coords.w-1] ;
  c_coord = [coords.y+coords.h-1, coords.x] ;
  d_coord = [coords.y, coords.x];

  % Find coordenades (x,y) of points a,b,c,d
  d_coord = d_coord - [1,1];
  b_coord = b_coord - [1,0];
  c_coord = c_coord - [0,1];

  % Careful, if the bounding box is touching a border
  % the corresponding part is equal to 0

  A=0;B=0;C=0;D=0;
  if a_coord(1) ~= 0 && a_coord(2) ~= 0
    A = ii(a_coord(1), a_coord(2));  
  end
  if b_coord(1) ~= 0 && b_coord(2) ~= 0
    B = ii(b_coord(1), b_coord(2));  
  end
  if c_coord(1) ~= 0 && c_coord(2) ~= 0
    C = ii(c_coord(1), c_coord(2));  
  end
  if d_coord(1) ~= 0 && d_coord(2) ~= 0
    D = ii(d_coord(1), d_coord(2));  
  end

  % Sum
  S = A - B - C + D;

  % Filling ratio
  fr = S/(coords.w*coords.h);
end

function vcomb = getCombinations(da, dims, ffs)
    %This function returns a vector of combinations of width and heigth.
    %The combinations are obtained considering that the values between the
    %intervals [min, max](obtained by the datasetAnalysis) are equiprobable.
    
    if(dims > 0 && ffs > 0)
        %Obtain the division period
        per_w = (da('all').w_max-da('all').w_min)/(ffs+1);
        per_ff = (da('all').ff_max-da('all').ff_min)/(ffs+1);
        %Preallocate vcomb
        vcomb(1:(dims*ffs)) = struct('w', 0, 'h', 0);
        %Calculate md and mf vectors of indices
        md=zeros(dims*ffs,1); %multiplier of the period of the dimension
        mf=zeros(dims*ffs,1); %multiplier of the period of the form_factor
        for d = 1:dims
            for f = 1:ffs
                c = f+(d-1)*dims;
                md(c) = d;
                mf(c) = f;
            end
        end
        
        %Calculate width and heigth combinations
        for c = 1:(dims*ffs)         
            vcomb(c).w = round(da('all').w_min+per_w*md(c));
            vcomb(c).h = round((da('all').w_min+per_w*md(c))/(da('all').ff_min+per_ff*mf(c)));
        end
        
    else
        error('incorrect number of dims or ffs');
    end   
end

% IntegralImage: Calculate the image integral
function [ii] = IntegralImage(mask)
  ii = cumsum(cumsum(mask,2));
end
