clc; clear; close all;
path = 'D:\Courses\Computer Vision Fundamentals\Homework\CV_Project\Dataset\';
directory = dir(path);
for l=3:numel(directory)
    if directory(l).isdir
        I = im2double(imread([path directory(l).name '\im0.png']));
        fid = fopen([path directory(l).name '\disp0.pfm'],'r');
        numChannels = 0;
        imWidth     = 0;
        imHeight    = 0;
        isBigEndian = 0;
        scaleFactor = 1;
        line1 = fgetl(fid);
        line2 = fgetl(fid);
        line3 = fgetl(fid);
        if strcmp(line1, 'PF') == 1
            numChannels = 3;
        elseif strcmp(line1, 'Pf') == 1
            numChannels = 1;
        end
        [dims, foundCount, errMsg] = sscanf(line2, '%u %u');
        imWidth  = dims(1);
        imHeight = dims(2);
        [scale, matchCount, errMsg] = sscanf(line3, '%f');
        scaleFactor = abs(scale);
        endianChar = 'n';
        if scale < 0.0
            isBigEndian = 0;
            endianChar = 'l';
        else
            isBigEndian = 1;
            endianChar = 'b';
        end
        img = zeros(imWidth, imHeight, numChannels);
        totElems = numel(img);
        [rawData, numFloatsRead] = fread(fid, totElems, 'single', 0, endianChar);
        fclose(fid);
        imDataInReadOrder = reshape(rawData, [numChannels, imWidth, imHeight]);
        image = zeros(imWidth, imHeight);
        for i=1:imWidth
            for j=1:imHeight
                image(i,j) = imDataInReadOrder(1,i,j);
            end
        end
        J = imrotate(image,90);
        out = 80;
        s = round(size(I,2) * ((100 - out) / 100));
        for k=1:s
            s1 = size(I,1);
            s2 = size(I,2);
            K = zeros(s1,s2);
            K(1,:) = J(1,:);
            for i=2:s1
                K(i,1) = J(i,1) + min(K(i-1,1:2));
                for j=2:s2-1
                    K(i,j) = J(i,j) + min(K(i-1,j-1:j+1));
                end
                K(i,s2) = J(i,s2) + min(K(i-1,s2-1:s2));
            end
            [val,idx] = min(K(s1,:));
            M = I;
            N = J;
            M(s1,idx:end-1,:) = I(s1,idx+1:end,:);
            N(s1,idx:end-1) = J(s1,idx+1:end);
            for i=s1-1:-1:1
                switch K(i+1,idx) - J(i+1,idx)
                    case K(i,max(idx-1,1))
                        idx = max(idx-1,1);
                    case K(i,min(idx+1,s2))
                        idx = min(idx+1,s2);
                end
                M(i,idx:end-1,:) = I(i,idx+1:end,:);
                N(i,idx:end-1) = J(i,idx+1:end);
            end
            I = M(:,1:end-1,:);
            J = N(:,1:end-1);
        end
        imwrite(I,[path directory(l).name '\out0.png']);
    end
end