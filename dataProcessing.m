% The code extracts results from NMF algorithm.
% This code is written by Eftychios A. Pnevmatikakis, Liam Paninski, Weijian Yang and Darcy S. Peterka

% note:
% signal_inferred: df/f data, spatial weighting on the ROI pixels, unmixing, background substraction, and denoising
% signal_filtered: df/f data, spatial weighting on the ROI pixels, unmixing, background substraction
% signal_raw: df/f data, no spatial weighting on the ROI pixels, whether background substraction is done depends on user input parameter "backgroundSubtractionforRaw" 
% signal_spike: detected spike event

% Set write_data=1 to save extracted traces (+ all parameters used to run the
% code) to a .mat file with a unique name (filename + date + CNMF.mat)
write_data_out=1; 


%did you merge ROIs?  Then use that data..."
if use_merged==1
    Cdat=Cm;
    Adat=Am;
    
else
    Cdat=C;
    Adat=A;
end
%% Data processing
% plot ROI contour
numberLabel=1;
contourColor=[1 0 0];
weigh_image=f_plotROIContour( Adat,d1,d2,numberLabel,contourColor );

% View results ROI by ROI
%f_view_patches_mod(Y,A,C,b,f,d1,d2);
ROIn=size(Adat,2);

% Extract calcium traces
backgroundSubtractionforRaw=1;              % user input: background substration for raw data?
baselineRatio=0.35;                         % to obtain df/f, what fraction of total values of trace (sorted ascending) are used to determine DC component of ROI
[ signal_inferred, signal_filtered, signal_raw ,signal_inferred_DC, signal_filtered_DC, signal_raw_DC,Y_fres] = f_signalExtraction_dfof(Y,Adat,Cdat,b,f,d1,d2,backgroundSubtractionforRaw,baselineRatio);

% Infer spike
method='temporalMatching';
method='derivative';

stdThreshold0=4.5; 
stdThresholdSlope=2.5;
lowpassCutoff=-1;
temporalWaveformThreshold=0.02;    % 0.025 for AP1, 
%set spike_find to "0" to avoid plotting events
spike_find=0;
if( spike_find)
    signal_spike=f_inferSpike(signal_inferred, frameRate, method, stdThreshold0, stdThresholdSlope, lowpassCutoff, gamma, temporalWaveformThreshold );
else
    signal_spike=zeros(size(signal_inferred));
end
    
if(write_data_out)
    data_writeNMF(datawrite,weigh_image,Adat, Ain, Cdat, Cin, b, f, signal_raw, signal_filtered, signal_inferred,Y_fres,use_merged);
end

%% Plot the signals
normalization=1; % if 0, no normalization, otherwise normalize each trace relative to its max value
separation=2;
labelling=1;
f_plotActivityTraceSpike( signal_raw, signal_filtered, signal_inferred, signal_spike, frameRate, normalization, separation, labelling);
f_view_patches_mod(Yr,A,C,b,f,d1,d2);
