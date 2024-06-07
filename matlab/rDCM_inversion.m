function output = rDCM_inversion(save_outputs,save_DCM,reduced_dataset,network,reduce_noise_thresh)
%-------------------------------------------------------------------------------------------------------
% performs rDCM inversion of timeseries with repetion time of 2.5s on all DCM.mat files within the directory with the option 
% for different settings
%  
%
% Input: 
%      
%       save_outputs    - if true: save outputs of inversion to .mat file for each sample (default:false)
%                                 
%       save_DCM        - if true: save DCM to .mat file for each sample (default:false)
%
%       reduced_dataset - if true: use a network of a reduced number of brain regions informed by 
%                                 anatomical considerations, else use 242
%                                 available regions from Brainnetome (default:false)
%    
%       network           - if using reduced_dataset:
%                               defines which network to use
%                                   - currently implemented:
%                                        - 'triple'
%                                        - 'pain'
%                               (default: 'none') 
%
%      reduce_noise_thresh  -set SNR threshold to the specified value during rDCM inversion (default=0)
%
%       sub_numbers      - indices of samples to be inverted. Has to be specified 
%     
% 
% Output: 
%
%       output           - all parameters received by rDCM inversion
%
%-------------------------------------------------------------------------------------------------------
[ParentCurDir, ~] = fileparts(pwd);
baseDir = fullfile(ParentCurDir,'SRPBS_OPEN','data');
   if ~exist("save_outputs","var")
        save_outputs=0;
   end
   if ~exist("save_DCM","var")
        save_DCM=0;
   end
   if ~exist("reduced_dataset","var")
        reduced_dataset=0;
        network = "none";
   end
   if ~exist("reduce_noise_thresh","var")
        reduce_noise_thresh=0;
   end
   files = dir(baseDir); 
   for k = files
        if k == '.' || k == '..' || k == 'Brainnetome2016'
        continue
        end
        sub_dir = k.name;
        file = fullfile(baseDir, sub, 'DCM.mat');
        DCM = load(file)
        if reduced_dataset
        A_reduced = get_reduced_connectivity_matrix(network);
        DCM.a=A_reduced;
        DCM.b=zeros(length(A_reduced),length(A_reduced),0);
        DCM.c=zeros(length(A_reduced),0);
        DCM.d=zeros(length(A_reduced),length(A_reduced),0);
        DCM.Y.y=DCM.Y.y(:,numerical_indices_to_keep);
        DCM.Y = rmfield(DCM.Y, 'name');
        DCM.n=length(A_reduced);
        end
        type='r'; %use a real dataset
        disp(DCM);
        options.visualize = 1;
        %set SNR threshold if specified 
        if reduce_noise_thresh > 0
            options.filter_str=thresh;
        else
            options.filter_str=0;
        end
        [output, options] = tapas_rdcm_estimate(DCM, type, options, 1);
        %save to .mat files, use different folders for complete and
        %incomplete subjects
        if save_outputs             
                if ~exist('outputs', 'dir')
                mkdir('outputs');
                end
                save('outputs\output_'+ string(k),'output')
                if ~exist('outputs_A', 'dir')
                mkdir('outputs_A');
                end
                save('outputs_A\output_'+ string(k),'output.A')
                if ~exist('outputs_F', 'dir')
                mkdir('outputs_F');
                end
                save('outputs_F\output_'+ string(k),'output.F')
        end
        if save_DCM
                if ~exist('DCMs', 'dir')
                mkdir('DCMs');
                end
                save('DCMs\DCM'+ string(k),'DCM')
        end   
   end