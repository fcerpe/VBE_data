%% Create csv of stimuli information to compute pixel distance RDMs
% 
% Assuming that the GitHub repository 'fcerpe/VisualBraille_backstageCode' 
% is cloned (may need to adjust the path), fecth the .mat file containing 
% the pixel information of each stimulus and create a pixel distance matrix
%
% Will just create a .csv that can be processed in R, for visualization 

% Path to the mat file
% (may need to be adjusted)
mat_path = '/Users/cerpelloni/Documents/GitHub/PHD/VisualBraille_backstageCode/VBE_final_design/mvpa_categories/blockMvpa_stimuli.mat';

% Load file and fetch images 
load(mat_path, 'images'); 

% Init table where to save stimulus, class, array of pixel values
pixels = table();

% Define the substructures from which we extract the sitmuli's pixels
classes = {'frw', 'fpw', 'fnw', 'ffs', 'brw', 'bpw', 'bnw', 'bfs'}; 

% Iterate through each relevant struct
for i = 1:length(classes)
    structName = classes{i};
    
    % Check if the struct exists in 'images'
    if isfield(images, structName)
        % Get the struct
        currentStruct = images.(structName);
        
        % Iterate through each 'w' variable (w1 to w12)
        for w = 1:12

            varName = sprintf('w%d', w); % Generate variable name (e.g., 'w1')
            
            % Check if the variable exists in the current struct
            if isfield(currentStruct, varName)

                % Get the matrix 
                matrix = currentStruct.(varName);
                
                % Crop it to remove part of the black outline
                cropped = matrix(56:end-35, 56:end-55);

                % Convert the array to a comma-separated string
                reshapedString = sprintf('%d,', reshapedArray); 
                reshapedString = reshapedString(1:end-1); % Remove the trailing comma
                
                % Add a row to the table
                pixels = [pixels; table({structName}, w, {reshapedString}, 'VariableNames', {'class', 'stimulus', 'pixels'})];
            end
        end
    end
end

% Display the resulting table
disp(pixels);

% Save the table to a csv
writetable(pixels, 'reports/stimuli_pixel_information.tsv', 'FileType', 'text', 'Delimiter', '\t', 'WriteVariableNames', true);

