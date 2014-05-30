function example_classifier

% change this path if you install the VOC code elsewhere
addpath([cd '/VOCcode']);

% initialize VOC options
VOCinit;

% train and test classifier for each class
for i=1:VOCopts.nclasses
    cls=VOCopts.classes{i};
    classifier=train(VOCopts,cls);                  % train classifier
    test(VOCopts,cls,classifier);                   % test classifier
    [fp,tp,auc]=VOCroc(VOCopts,'comp1',cls,true);   % compute and display ROC
    
    if i<VOCopts.nclasses
        fprintf('press any key to continue with next class...\n');
        pause;
    end
end

% train classifier
function classifier = train(VOCopts,cls)

% load 'train' image set for class
[ids,classifier.gt]=textread(sprintf(VOCopts.clsimgsetpath,cls,'train'),'%s %d');

% extract features for each image
classifier.FD=zeros(0,length(ids));
tic;
for i=1:length(ids)
    % display progress
    if toc>1
        fprintf('%s: train: %d/%d\n',cls,i,length(ids));
        drawnow;
        tic;
    end

    img_box  = imread(sprintf(VOCopts.imgpath,ids{i}));
    color_path = sprintf(VOCopts.color_path, 10, 1, ids{i});
    fd = mean_rgb_patch( img_box, 10, color_path)';
    
%     try
%         % try to load features
%         load(sprintf(VOCopts.exfdpath,ids{i}),'fd');
%     catch
%         % compute and save features
%         I=imread(sprintf(VOCopts.imgpath,ids{i}));
%         fd=extractfd(VOCopts,I);
%         save(sprintf(VOCopts.exfdpath,ids{i}),'fd');
%     end
    
    classifier.FD(1:length(fd),i)=fd;
end

% run classifier on test images
function test(VOCopts,cls,classifier)

% load test set ('val' for development kit)
[ids,gt]=textread(sprintf(VOCopts.clsimgsetpath,cls,VOCopts.testset),'%s %d');

% create results file
fid=fopen(sprintf(VOCopts.clsrespath,'comp1',cls),'w');

% classify each image
tic;
for i=1:length(ids)
    % display progress
    if toc>1
        fprintf('%s: test: %d/%d\n',cls,i,length(ids));
        drawnow;
        tic;
    end
    
    img_box  = imread(sprintf(VOCopts.imgpath,ids{i}));
    color_path = sprintf(VOCopts.color_path, 10, 1, ids{i});
    fd = mean_rgb_patch( img_box, 10, color_path)';
    
%     try
%         % try to load features
%         load(sprintf(VOCopts.exfdpath,ids{i}),'fd');
%     catch
%         % compute and save features
%         I=imread(sprintf(VOCopts.imgpath,ids{i}));
%         fd=extractfd(VOCopts,I);
%         save(sprintf(VOCopts.exfdpath,ids{i}),'fd');
%     end

    % compute confidence of positive classification
    c=classify(VOCopts,classifier,fd);
    
    % write to results file
    fprintf(fid,'%s %f\n',ids{i},c);
end

% close results file
fclose(fid);

% trivial feature extractor: compute mean RGB
function fd = extractfd(VOCopts,I)

fd = [];
[nr,nc,nz] = size(I);
for i=1:10,
	for j=1:10,
		dv = I(floor(1+(i-1)*nr/10):floor(i*nr/10),floor(1+(j-1)*nc/10):floor(j*nc/10),:);
		fd = [fd;sum(sum(double(dv)))/(size(dv,1)*size(dv,2))];
%fd=squeeze(sum(sum(double(I)))/(size(I,1)*size(I,2)));
	end
end
fd = fd(:);

% trivial classifier: compute ratio of L2 distance betweeen
% nearest positive (class) feature vector and nearest negative (non-class)
% feature vector
function c = classify(VOCopts,classifier,fd)

d=sum(fd.*fd)+sum(classifier.FD.*classifier.FD)-2*fd'*classifier.FD;
dp=min(d(classifier.gt>0));
dn=min(d(classifier.gt<0));
c=dn/(dp+eps);