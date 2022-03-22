%%% *********************************************************************
%%% * E2E Latency Analysis of Decentralized Blockchain                  *
%%% * By: Francesc Wilhelmi (fwilhelmi@cttc.cat) & Paolo Dini           *
%%% * Copyright (C) 2020-2025, and GNU GPLd, by Francesc Wilhelmi       *
%%% * Repo.: bitbucket.org/francesc_wilhelmi/model_blockchain_delay     *
%%% *********************************************************************

% FILE DESCRIPTION: this file processes the output of the simulator for the
% block size optimization part

% Arrays to store results
for t = 1 : length(T_WAIT)
    for m = 1 : length(mu)
        total_transactions{t,m} = zeros(length(lambda), length(block_size));
        transactions_dropped{t,m} = zeros(length(lambda), length(block_size));
        drop_percentage{t,m} = zeros(length(lambda), length(block_size));
        num_blocks_mined_by_timeout{t,m} = zeros(length(lambda), length(block_size));
        mean_occupancy{t,m} = zeros(length(lambda), length(block_size));
        mean_delay{t,m} = zeros(length(lambda), length(block_size));  
        p_fork_sim{t,m} = zeros(length(lambda), length(block_size));  
    end
end

for t = 1 : length(T_WAIT)
   
    if T_WAIT(t) == 0.1
        timer = '01';
    else
        timer = num2str(T_WAIT(t));
    end
    
    % Files directory
    if FORKS_ENABLED
        files_path = ['simulation_data/block_size_optimization/forks/t_' timer];
    else
        files_path = ['simulation_data/block_size_optimization/no_forks/t_' timer];
    end
    files_dir = dir([files_path '/*.txt']);

    % Iterate for each file in the directory
    for i = 1 : length(files_dir)
        % Get the name of the file being analyzed
        file_name = files_dir(i).name;  
        % Find the parameters used (timer, lambda & block size)
        % - Timer
        split01 = strsplit(file_name,'_');
        ix = 3;
%        if FORKS_ENABLED, ix = ix+1; end
        split02 = strsplit(split01{ix},'m');
        m = str2double(split02{2});
        ix_m = find(mu==m);
        % - Lambda
        split1 = strsplit(file_name,'_');
        ix = 4;
        %if FORKS_ENABLED, ix = ix+1; end
        split2 = strsplit(split1{ix},'l');
        l = str2double(split2{2});
%         if FORKS_ENABLED
%             ix_l = find(lambda/M==l);
%         else
%            ix_l = find(lambda==l);
%         end
        ix_l = find(lambda==l);
        % - Block size
        ix = 5;
        %if FORKS_ENABLED, ix = ix+1; end
        split3 = strsplit(split1{ix},'s');
        split4 = strsplit(split3{2},'.');
        s = str2double(split4{1});
        ix_s = find(block_size==s);
        % Read the file
        if isempty(ix_m) || isempty(ix_l)
            % Skip this file
            disp(file_name)
        else
            file_data = fopen([files_path '/' file_name]);
            A = textscan(file_data,'%s','Delimiter',';');
            B = str2double(A{:});    
            % Store results to variables
            total_transactions{t,ix_m}(ix_l,ix_s) = B(2);
            transactions_dropped{t,ix_m}(ix_l,ix_s) = B(3);
            drop_percentage{t,ix_m}(ix_l,ix_s) = B(4);
            num_blocks_mined_by_timeout{t,ix_m}(ix_l,ix_s) = B(5);
            mean_occupancy{t,ix_m}(ix_l,ix_s) = B(6);
            mean_delay{t,ix_m}(ix_l,ix_s) = B(7);     
            if FORKS_ENABLED
                p_fork_sim{t,ix_m}(ix_l,ix_s) = B(8);  
            end
            fclose(file_data);
        end
    end
    
end

% Save workspace
if FORKS_ENABLED
    save('tmp/simulator_output_forks')
else
    save('tmp/simulator_output_no_forks')
end