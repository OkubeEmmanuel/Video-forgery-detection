function tempered = video_corr(video)
    
    wait = waitbar(0,'Please wait, video is processing...');
    
    %Get the total number of frames the video has
    numFrames = get(video,'NumberOfFrames');

    %Process to extract all frames from the video.
    for k=1:numFrames
        waitbar(k/numFrames);
        
        thisframe = read(video,k);

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
    lb = mn - (3.4 * sd);
    ub = mn + (3.4 * sd); 
    %Abnormal point counter variable
    y = 0;

    for x = 1:p    
        if( (cor(1,x) < lb) || (cor(1,x) > ub) )
            y = y + 1;
            abnormal_point(1,y) = x;
        end
    end
    
    if(y > 0)
        tempered = 1;
    else
        tempered = 0;
    end
end