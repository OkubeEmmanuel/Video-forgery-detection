clc
close all
clear; 
%Load the video to test
[filename, filepath] = uigetfile({'*.mp4';'*.avi';'*.3gp'},'Select data file');

if filepath == 0       
    info = msgbox('No file selected, please try again.');
else
    wait = waitbar(0,'Please wait, video is processing...');
    
    v = VideoReader(fullfile(filepath,filename));
    
    %Get the total number of frames the video has
    numFrames = get(v,'NumberOfFrames');

    %Process to extract all frames from the video.
    for k=1:numFrames
        waitbar(k/numFrames);
        
        thisframe = read(v,k);

        %resize frame to acceptable size to enable fast processing
        thisframe = imresize(thisframe,[480,640]);

        %Store RGB frames in specified folder
        name = strcat('orgframes/frame',int2str(k),'.jpg');
        thisfile=sprintf(name,k);
        imwrite(thisframe,thisfile);

        %change RGB images to BW
        grayimage = rgb2gray(thisframe);
        
        %Store BW frames in a specified folder.
        name = strcat('bwframes/frame',int2str(k),'.jpg');
        thisfile=sprintf(name,k);
        imwrite(grayimage,thisfile);
    end
    close(wait);
    
    wait = waitbar(0,'Please wait, video is processing...');
    n = numFrames - 1;

    %Create array to hold values of inter-frame correlation coefficient between adjacent frames
    cor = zeros(1,n);
    for i = 1:n
        waitbar(i/n);
        
        name1 = strcat('bwframes/frame',int2str(i),'.jpg');
        name2 = strcat('bwframes/frame',int2str((i+1)),'.jpg');
        image1 = imread(name1);
        image2 = imread(name2);
        
        %calculate the inter-frame correlation coefficient between adjacent frames
        cor(1,i) = corr2(image1, image2);
    end
    close(wait);
    
    wait = waitbar(0,'Please wait, video is processing...');
    p = n-1;
    %create array to store differece of correlation of adjacent frames
    diff = zeros(1,p);
    
    for l = 1:p
        waitbar(l/p);
         
        diff(1,l) = cor(1,l) - cor(1,(l+1));
        if( isnan(diff(1,l)) )
            diff(1,l) = 0;
        end
    end
    close(wait);

    %calculate mean of corelation difference
    mn = mean(cor);
    
    %calculate standard deviation of corelation difference
    sd = std(cor);

    %using the 3 sigma rule to set extreme values in the distribution
    lb = mn - (6.0 * sd);
    ub = mn + (6.0 * sd); 

    %Abnormal point counter variable
    y = 0;

    for x = 1:p    
        if( (cor(1,x) < lb) || (cor(1,x) > ub) )
            y = y + 1;
            abnormal_point(1,y) = x;
        end
    end

    plot(diff);

    flag = 0;

    if(y > 0)
        for x = 1:y
%             if (flag == 1)
%                 flag = 0;
%                 continue
%             end
            value = abnormal_point(1,x);

            pause
            figure
            subplot(2,2,1)
            name = strcat('orgframes/frame',int2str(value),'.jpg');
            image = imread(name);
            imshow(image)
            title('1st frame in Tampered Sequence')

            subplot(2,2,2)
            name = strcat('orgframes/frame',int2str((value+1)),'.jpg');
            image = imread(name);
            imshow(image)
            title('2nd frame in Tampered Sequence')

            subplot(2,2,3)
            name = strcat('orgframes/frame',int2str((value+2)),'.jpg');
            image = imread(name);
            imshow(image)
            title('3rd frame in Tampered Sequence')

            subplot(2,2,4)
            name = strcat('orgframes/frame',int2str((value+3)),'.jpg');
            image = imread(name);
            imshow(image)
            title('4th frame in Tampered Sequence')

            flag = 1;
        end
    end
    pause;
    
    if(y > 0)
        info = msgbox('This video might have been tamperd with.');
    else
        info = msgbox('This video looks genuine.');
    end
    close all;
end
