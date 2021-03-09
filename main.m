close all
clear; 
%Load the video to test
%[filename, filepath] = uigetfile({'*.mp4';'*.avi';'*.3gp'},'Select data file');

%Declare and initialize matrix variables 
TP = 0;
TN = 0;
FP = 0;
FN = 0;
c = 1;
tampered_folder = 'tampered';
untampered_folder = 'original';

%Read mp4 files from forged folder
s = dir(strcat(tampered_folder,'/*.mp4'));
forged_files={s.name};
disp(forged_files);

%Read mp4 files from original folder
s = dir(strcat(untampered_folder,'/*.mp4'));
original_files={s.name};
disp(original_files);

%Number of forged videos
nfv = numel(forged_files);
fvt = ones(1, nfv);

%Number of original videos
nov = numel(original_files);
orgt = zeros(1, nov);

targets = [orgt, fvt];
outputs = zeros(1, (nfv + nov));

%Analyse original videos
for k=1:numel(original_files)
    v = VideoReader(fullfile(untampered_folder,original_files{k}));
    result = video_corr(v);
    outputs(c) = result;
    c = c+1;
    
    if result == 1
        FP = FP + 1; 
    else
        TN = TN + 1;
    end
end

%Analyse forged videos
for k=1:numel(forged_files)
    v = VideoReader(fullfile(tampered_folder,forged_files{k}));
    result = video_corr(v);
    outputs(c) = result;
    c = c+1;
    
    if result == 1
        TP = TP + 1;
    else
        FN = FN + 1;
    end
end
    
accuracy = (TP + TN)/(TP + FP + FN + TN) * 100;
precision = TP/(TP+FP);
recall = TP/(TP+FP);
f1_score = 2 * (recall * precision)/(recall + precision);

X = sprintf('Accuracy: %.2f %',accuracy);
disp(X)
X = sprintf('Precision: %.2f',precision);
disp(X)
X = sprintf('Recall: %.2f',recall);
disp(X)
X = sprintf('F1 Score: %.2f',f1_score);
disp(X)

plotconfusion(targets,outputs);
%plotroc(targets,outputs);