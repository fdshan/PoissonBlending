function imgout = poisson_blend(im_s, mask_s, im_t)
% -----Input
% im_s     source image (object)
% mask_s   mask for source image (1 meaning inside the selected region)
% im_t     target image (background)
% -----Output
% imgout   the blended image


% nb: channel number
[imh, imw, nb] = size(im_s);

%V is a look-up table
V = zeros(imh, imw);
V(1:imh*imw) = 1:imh*imw;
%TODO: consider different channel numbers
% edit in main.m
% reference: https://www.mathworks.com/matlabcentral/answers/91036-how-do-i-split-a-color-image-into-its-3-rgb-channels

e = 1;
i = [];
j = [];
v = [];
%TODO: initialize counter, A (sparse matrix) and b.
%Note: A don't have to be kk,
%      you can add useless variables for convenience,
%      e.g., a total of imh*imw variables

b = zeros(imh*imw, 1);

%TODO: fill the elements in A and b, for each pixel in the image
%compute gradients for v following im_s
% consider four neighbours, whether is inside the region or outside the region
for y = 1:imh
    for x = 1:imw
        
        %pixel outside the region,
        if mask_s(y,x) == 0
            ii = [e];
            jj = [V(y,x)];
            vv = [1];
            b(e) = im_t(y,x);
        end
        %consider the pixels in the selected region
        if mask_s(y,x) == 1
            if mask_s(y,x+1) == 1 && mask_s(y,x-1) == 1 && mask_s(y+1,x) == 1 && mask_s(y-1,x) == 1
                ii = [e, e, e, e, e];
                jj = [V(y,x), V(y,x+1), V(y,x-1), V(y+1,x), V(y-1,x)];
                vv = [4, -1, -1, -1, -1];
                b(e) = 4*im_s(y,x) - im_s(y,x+1) - im_s(y,x-1) - im_s(y+1,x) - im_s(y-1,x);
                
            elseif mask_s(y,x+1) == 0 && mask_s(y,x-1) == 1 && mask_s(y+1,x) == 1 && mask_s(y-1,x) == 1
                ii = [e, e, e, e];
                jj = [V(y,x), V(y,x-1), V(y+1,x), V(y-1,x)];
                vv = [4, -1, -1, -1];
                b(e) = im_t(y,x+1) + 4*im_s(y,x) - im_s(y,x+1) - im_s(y,x-1) - im_s(y+1,x) - im_s(y-1,x);
            elseif mask_s(y,x+1) == 1 && mask_s(y,x-1) == 0 && mask_s(y+1,x) == 1 && mask_s(y-1,x) == 1
                ii = [e, e, e, e];
                jj = [V(y,x), V(y,x+1), V(y+1,x), V(y-1,x)];
                vv = [4, -1, -1, -1];
                b(e) = im_t(y,x-1) + 4*im_s(y,x) - im_s(y,x+1) - im_s(y,x-1) - im_s(y+1,x) - im_s(y-1,x);
            elseif mask_s(y,x+1) == 1 && mask_s(y,x-1) == 1 && mask_s(y+1,x) == 0 && mask_s(y-1,x) == 1
                ii = [e, e, e, e];
                jj = [V(y,x), V(y,x+1), V(y,x-1), V(y-1,x)];
                vv = [4, -1, -1, -1];
                b(e) = im_t(y+1,x) + 4*im_s(y,x) - im_s(y,x+1) - im_s(y,x-1) - im_s(y+1,x) - im_s(y-1,x);
            elseif mask_s(y,x+1) == 1 && mask_s(y,x-1) == 1 && mask_s(y+1,x) == 1 && mask_s(y-1,x) == 0
                ii = [e, e, e, e];
                jj = [V(y,x), V(y,x+1), V(y,x-1), V(y+1,x)];
                vv = [4, -1, -1, -1];
                b(e) = im_t(y-1,x) + 4*im_s(y,x) - im_s(y,x+1) - im_s(y,x-1) - im_s(y+1,x) - im_s(y-1,x);
                
                
            elseif mask_s(y,x+1) == 0 && mask_s(y,x-1) == 0 && mask_s(y+1,x) == 1 && mask_s(y-1,x) == 1
                ii = [e, e, e];
                jj = [V(y,x), V(y+1,x), V(y-1,x)];
                vv = [4, -1, -1];
                b(e) = im_t(y,x+1) + im_t(y,x-1) + 4*im_s(y,x) - im_s(y,x+1) - im_s(y,x-1) - im_s(y+1,x) - im_s(y-1,x);
            elseif mask_s(y,x+1) == 0 && mask_s(y,x-1) == 1 && mask_s(y+1,x) == 0 && mask_s(y-1,x) == 1
                ii = [e, e, e];
                jj = [V(y,x), V(y,x-1), V(y-1,x)];
                vv = [4, -1, -1];
                b(e) = im_t(y+1,x) + im_t(y,x+1) + 4*im_s(y,x) - im_s(y,x+1) - im_s(y,x-1) - im_s(y+1,x) - im_s(y-1,x);
            elseif mask_s(y,x+1) == 0 && mask_s(y,x-1) == 1 && mask_s(y+1,x) == 1 && mask_s(y-1,x) == 0
                ii = [e, e, e];
                jj = [V(y,x), V(y,x-1), V(y+1,x)];
                vv = [4, -1, -1];
                b(e) = im_t(y,x+1) + im_t(y-1,x) + 4*im_s(y,x) - im_s(y,x+1) - im_s(y,x-1) - im_s(y+1,x) - im_s(y-1,x);
            elseif mask_s(y,x+1) == 1 && mask_s(y,x-1) == 0 && mask_s(y+1,x) == 0 && mask_s(y-1,x) == 1
                ii = [e, e, e];
                jj = [V(y,x), V(y,x+1), V(y-1,x)];
                vv = [4, -1, -1];
                b(e) = im_t(y,x-1) + im_t(y+1,x) + 4*im_s(y,x) - im_s(y,x+1) - im_s(y,x-1) - im_s(y+1,x) - im_s(y-1,x);
            elseif mask_s(y,x+1) == 1 && mask_s(y,x-1) == 0 && mask_s(y+1,x) == 1 && mask_s(y-1,x) == 0
                ii = [e, e, e];
                jj = [V(y,x), V(y,x+1), V(y+1,x)];
                vv = [4, -1, -1];
                b(e) = im_t(y-1,x) + im_t(y,x-1) + 4*im_s(y,x) - im_s(y,x+1) - im_s(y,x-1) - im_s(y+1,x) - im_s(y-1,x);
            elseif mask_s(y,x+1) == 1 && mask_s(y,x-1) == 1 && mask_s(y+1,x) == 0 && mask_s(y-1,x) == 0
                ii = [e, e, e];
                jj = [V(y,x), V(y,x+1), V(y,x-1)];
                vv = [4, -1, -1];
                b(e) = im_t(y+1,x) + im_t(y-1,x) + 4*im_s(y,x) - im_s(y,x+1) - im_s(y,x-1) - im_s(y+1,x) - im_s(y-1,x);
                
                
            elseif mask_s(y,x+1) == 0 && mask_s(y,x-1) == 0 && mask_s(y+1,x) == 0 && mask_s(y-1,x) == 1
                ii = [e, e];
                jj = [V(y,x), V(y-1,x)];
                vv = [4, -1];
                b(e) = im_t(y,x+1) + im_t(y,x-1) + im_t(y+1,x) + 4*im_s(y,x) - im_s(y,x+1) - im_s(y,x-1) - im_s(y+1,x) - im_s(y-1,x);
            elseif mask_s(y,x+1) == 0 && mask_s(y,x-1) == 0 && mask_s(y+1,x) == 1 && mask_s(y-1,x) == 0
                ii = [e, e];
                jj = [V(y,x), V(y+1,x)];
                vv = [4, -1];
                b(e) = im_t(y,x+1) + im_t(y,x-1) + im_t(y-1,x) + 4*im_s(y,x) - im_s(y,x+1) - im_s(y,x-1) - im_s(y+1,x) - im_s(y-1,x);
            elseif mask_s(y,x+1) == 0 && mask_s(y,x-1) == 1 && mask_s(y+1,x) == 0 && mask_s(y-1,x) == 0
                ii = [e, e];
                jj = [V(y,x), V(y,x-1)];
                vv = [4, -1];
                b(e) = im_t(y,x+1) + im_t(y+1,x) + im_t(y-1,x) + 4*im_s(y,x) - im_s(y,x+1) - im_s(y,x-1) - im_s(y+1,x) - im_s(y-1,x);
            elseif mask_s(y,x+1) == 1 && mask_s(y,x-1) == 0 && mask_s(y+1,x) == 0 && mask_s(y-1,x) == 0
                ii = [e, e];
                jj = [V(y,x), V(y,x+1)];
                vv = [4, -1];
                b(e) = im_t(y,x-1) + im_t(y+1,x) + im_t(y-1,x) + 4*im_s(y,x) - im_s(y,x+1) - im_s(y,x-1) - im_s(y+1,x) - im_s(y-1,x);
                
                
            elseif mask_s(y,x+1) == 0 && mask_s(y,x-1) == 0 && mask_s(y+1,x) == 0 && mask_s(y-1,x) == 0
                ii = [e];
                jj = [V(y,x)];
                vv = [4];
                b(e) = im_t(y,x+1) + im_t(y,x-1) + im_t(y+1,x) + im_t(y-1,x) + 4*im_s(y,x) - im_s(y,x+1) - im_s(y,x-1) - im_s(y+1,x) - im_s(y-1,x);
            end
        end
        i = [i, ii];
        j = [j, jj];
        v = [v, vv];
        e = e + 1;
    end
end

A = sparse(i, j, v);

%fprintf('sizeA=%d',size(A));
%fprintf('sizeb=%d',size(b));

%TODO: add extra constraints (if any)


%TODO: solve the equation
%use "lscov" or "\", please google the matlab documents
solution = A\b;
error = sum(abs(A*solution-b));
disp(error)
imgout = reshape(solution,[imh,imw]);



end