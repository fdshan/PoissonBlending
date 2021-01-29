clc;
clear;
close all;

im_background = im2double(imread('./target_3.jpg'));
im_object = im2double(imread('./source_3.jpg'));

% get source region mask from the user
objmask = get_mask(im_object);

% align im_s and mask_s with im_background
[im_s, mask_s] = align_source(im_object, objmask, im_background);

% blend
disp('start');
if (ndims(im_s) == 3)
    % for RGB image
    im_blend_red = poisson_blend(im_s(:,:,1), mask_s, im_background(:,:,1));
    im_blend_green = poisson_blend(im_s(:,:,2), mask_s, im_background(:,:,2));
    im_blend_blue = poisson_blend(im_s(:,:,3), mask_s, im_background(:,:,3));
    im_blend = cat(3, im_blend_red, im_blend_green, im_blend_blue);
else
    %for grayscale image
    im_blend = poisson_blend(im_s, mask_s, im_background);
end

disp('end');

imwrite(im_blend,'output.png');
figure(), hold off, imshow(im_blend);
