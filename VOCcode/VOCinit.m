clear VOCopts

% get current directory with forward slashes

addpath('../lib/sift')

% add weka path
if strncmp(computer,'PC',2)
    javaaddpath('C:\Program Files\Weka-3-7\weka.jar');
elseif strncmp(computer,'GLNX',4)
    javaaddpath('/home/evargasv/weka-3-7-11/weka.jar');
elseif strncmp(computer,'MACI64',3)
    javaaddpath('/Applications/weka-3-7-11-apple-jvm.app/Contents/Resources/Java/weka.jar')
end

import weka.*;


cwd=cd;
cwd(cwd=='\')='/';

% change this path to point to your copy of the PASCAL VOC data
VOCopts.datadir=[cwd '/'];

% change this path to a writable directory for your results
VOCopts.resdir=[cwd '/results/'];

% change this path to a writable local directory for the example code
VOCopts.localdir=[cwd '/local/'];

% initialize the test set

VOCopts.testset='val'; % use validation data for development test set
% VOCopts.testset='test'; % use test set for final challenge

% initialize paths

VOCopts.imgsetpath=[VOCopts.datadir 'VOC2006/ImageSets/%s.txt'];
VOCopts.clsimgsetpath=[VOCopts.datadir 'VOC2006/ImageSets/%s_%s.txt'];
VOCopts.annopath=[VOCopts.datadir 'VOC2006/Annotations/%s.txt'];
VOCopts.imgpathfolder=[VOCopts.datadir 'VOC2006/PNGImages/'];
VOCopts.imgpath=[VOCopts.imgpathfolder '%s.png'];
VOCopts.clsrespath=[VOCopts.resdir '%s_cls_' VOCopts.testset '_%s.txt'];
VOCopts.detrespath=[VOCopts.resdir '%s_det_' VOCopts.testset '_%s.txt'];

% initialize the VOC challenge options

VOCopts.classes={'bicycle','bus','car','cat','cow','dog',...
                'horse','motorbike','person','sheep'};
% VOCopts.classes={'bus'};

VOCopts.nclasses=length(VOCopts.classes);
VOCopts.minoverlap=0.5;

% initialize example options

VOCopts.dictpath = [VOCopts.localdir 'dictionary/'];
VOCopts.dictclasspath = [VOCopts.dictpath ,'%s/'];

VOCopts.dictpath_global = [VOCopts.localdir 'dictionary_global/'];
VOCopts.dictclasspath_global = [VOCopts.dictpath_global ,'%s/'];


VOCopts.exfdpath=[VOCopts.localdir '%s_fd.mat'];
VOCopts.exbgpath=[VOCopts.localdir 'bg_%s.mat'];
