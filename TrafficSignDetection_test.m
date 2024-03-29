%
% Template example for using on the test set (no annotations).
% 
 
function TrafficSignDetection_test(input_dir, output_dir, pixel_method, window_method, decision_method)
    % TrafficSignDetection_test('datasets/test', 'results/week4/method1_ccl_corr', 'hsv-morph_op2', 'ccl_corr', '')
    % TrafficSignDetection_test('datasets/test', 'results/week4/method1_ccl_sub', 'hsv-morph_op2', 'ccl_sub', '')
    % TrafficSignDetection_test('datasets/test', 'results/week4/method3_template', 'hsv-morph_op2', 'template_matching', '')
    addpath(genpath('.'));
    % TrafficSignDetection
    % Perform detection of Traffic signs on images. Detection is performed first at the pixel level
    % using a color segmentation. Then, using the color segmentation as a basis, the most likely window 
    % candidates to contain a traffic sign are selected using basic features (form factor, filling factor). 
    % Finally, a decision is taken on these windows using geometric heuristics (Hough) or template matching.
    %
    %    Parameter name      Value
    %    --------------      -----
    %    'input_dir'         Directory where the test images to analize  (.jpg) reside
    %    'output_dir'        Directory where the results are stored
    %    'pixel_method'      Name of the color space: 'opp', 'normrgb', 'lab', 'hsv', etc. (Weeks 2-5)
    %    'window_method'     'SegmentationCCL' or 'SlidingWindow' (Weeks 3-5)
    %    'decision_method'   'GeometricHeuristics' or 'TemplateMatching' (Weeks 4-5)


    global CANONICAL_W;        CANONICAL_W = 64;
    global CANONICAL_H;        CANONICAL_H = 64;
    global SW_STRIDEX;         SW_STRIDEX = 8;
    global SW_STRIDEY;         SW_STRIDEY = 8;
    global SW_CANONICALW;      SW_CANONICALW = 32;
    global SW_ASPECTRATIO;     SW_ASPECTRATIO = 1;
    global SW_MINS;            SW_MINS = 1;
    global SW_MAXS;            SW_MAXS = 2.5;
    global SW_STRIDES;         SW_STRIDES = 1.2;


    % Load models
    %global circleTemplate;
    %global givewayTemplate;   
    %global stopTemplate;      
    %global rectangleTemplate; 
    %global triangleTemplate;  
    %
    %if strcmp(decision_method, 'TemplateMatching')
    %   circleTemplate    = load('TemplateCircles.mat');
    %   givewayTemplate   = load('TemplateGiveways.mat');
    %   stopTemplate      = load('TemplateStops.mat');
    %   rectangleTemplate = load('TemplateRectangles.mat');
    %   triangleTemplate  = load('TemplateTriangles.mat');
    %end
    
    if (7==exist(output_dir,'dir'))
        rmdir(output_dir, 's');
    end
    status = mkdir(output_dir);
    if~status
        error('results_directory creation');
    end
    
    files = ListFiles(input_dir);
    datasetAnalysis = DatasetAnalysis('datasets/train');
    
    for ii=1:size(files,1)

        ii
        
        % Read file
        im = imread(strcat(input_dir,'/',files(ii).name));
     
        % Candidate Generation (pixel) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if(window_method ~= 'template_matching' && window_method ~= 'hough')
            pixelCandidates = CandidateGenerationPixel_Color(im, pixel_method);
        end
        
        % Candidate Generation (window)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        windowCandidates = CandidateGenerationWindow(pixelCandidates, window_method, datasetAnalysis, im); 
        
        out_file1 = sprintf ('%s/windowCandidates_%06d.png',  output_dir, ii);
	    out_file2 = sprintf ('%s/windowCandidates_%06d.mat', output_dir, ii);

	    imwrite (pixelCandidates, out_file1);
	    save (out_file2, 'windowCandidates');        
    end
end
 

