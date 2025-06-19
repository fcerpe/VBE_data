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

stimuli_list_path = '/Users/cerpelloni/Documents/GitHub/PHD/VisualBraille_backstageCode/VBE_final_design/mvpa_categories/stimuli_list.csv';
stimuli_list = readcell(stimuli_list_path);

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

                % Reshape as array of 1 by X dimensions
                array = reshape(matrix, 1, []);

                % Cast non-0 pixels to 255, to ease computations
                array(array ~= 0) = 255;

                % Create "whites column" to consider only active pixels 
                whites = length(array(array > 0)); 

                % Add a row to the table
                pixels = [pixels; table({structName}, w, {array}, whites, ...
                          'VariableNames', {'class', 'stimulus', 'pixels', 'whites'})];
            end
        end
    end
end

% Get number of strokes and dots for each stimulus
for iP = 1:(size(pixels,1)/2)
    
    % False fonts have different strokes, but not different dots
    if iP > 37, fs = true;
    else, fs = false; 
    end

    % Get stimulus
    strokes(iP) = getNumberStrokes(stimuli_list{iP}, fs);

    strokes(iP+48) = getNumberDots(stimuli_list{iP});
end

pixels.strokes = strokes(:);
% Display the resulting table
disp(pixels);


%% Clean table to contain position and number of white pixels 
%
% Make subtraction between whites and between overall pixel positions
% Divide for each script, to avoid unnecessary comparisons


% French (Latin) alphabet
% Initialize the matrices to store the RDMs of number of white pixels and of position 
rdmNbFrench = zeros(48);
rdmPosFrench = zeros(48);
rdmStrokesFrench = zeros(48);
rdmAvgStrokeFrench = zeros(4);

% Create submatrices for French 
fRows = startsWith(pixels.class, 'f');
nbRows = sum(fRows);
fWhites = pixels.whites(fRows == 1);
fPixels = pixels.pixels(fRows == 1);
fStrokes = pixels.strokes(fRows == 1);

fStrokesAvg = zeros(4,1); 
fStrokesAvg(1) = mean(fStrokes(1:12));
fStrokesAvg(2) = mean(fStrokes(13:24));
fStrokesAvg(3) = mean(fStrokes(25:36));
fStrokesAvg(4) = mean(fStrokes(37:48));

for iS = 1:length(fStrokesAvg)
    for jS = 1:length(fStrokesAvg)

        rdmAvgStrokeFrench(iS,jS) = abs(fStrokesAvg(iS) - fStrokesAvg(jS));
        rdmAvgStrokeFrench(jS,iS) = rdmAvgStrokeFrench(iS,jS);

    end
end

% Compute the pairwise differences between values of French script
% Ensure that whitesF has at least 48 values to create a 48x48 matrix
for i = 1:nbRows
    for j = 1:nbRows

        % Compute difference for number of white pixels
        rdmNbFrench(i,j) = abs(fWhites(i) - fWhites(j));
        rdmNbFrench(j,i) = rdmNbFrench(i,j);

        % Compute difference taking into account position of pixels
        rdmPosFrench(i,j) = sum(fPixels{i} ~= fPixels{j});
        rdmPosFrench(j,i) = rdmPosFrench(i,j);

        rdmStrokesFrench(i,j) = abs(fStrokes(i) - fStrokes(j));
        rdmStrokesFrench(j,i) = rdmStrokesFrench(i,j);

    end
end


% Braille alphabet
% Initialize the matrices to store the RDMs of number of white pixels and of position 
rdmNbBraille = zeros(48);
rdmPosBraille = zeros(48);
rdmStrokesBraille = zeros(48);
rdmAvgStrokeBraille = zeros(4);

% Create submatrices for Braille 
bRows = startsWith(pixels.class, 'b');
nbRows = sum(fRows);
bWhites = pixels.whites(bRows == 1);
bPixels = pixels.pixels(bRows == 1);
bStrokes = pixels.strokes(bRows == 1);

bStrokesAvg = zeros(4,1); 
bStrokesAvg(1) = mean(bStrokes(1:12));
bStrokesAvg(2) = mean(bStrokes(13:24));
bStrokesAvg(3) = mean(bStrokes(25:36));
bStrokesAvg(4) = mean(bStrokes(37:48));

for iS = 1:length(bStrokesAvg)
    for jS = 1:length(bStrokesAvg)

        rdmAvgStrokeBraille(iS,jS) = abs(bStrokesAvg(iS) - bStrokesAvg(jS));
        rdmAvgStrokeBraille(jS,iS) = rdmAvgStrokeBraille(iS,jS);

    end
end

% Compute the pairwise differences between values of French script
% Ensure that whitesF has at least 48 values to create a 48x48 matrix
for i = 1:nbRows
    for j = 1:nbRows

        % Compute difference for number of white pixels
        rdmNbBraille(i,j) = abs(bWhites(i) - bWhites(j));
        rdmNbBraille(j,i) = rdmNbBraille(i,j);

        % Compute difference taking into account position of pixels
        rdmPosBraille(i,j) = sum(bPixels{i} ~= bPixels{j});
        rdmPosBraille(j,i) = rdmPosBraille(i,j);

        rdmStrokesBraille(i,j) = abs(bStrokes(i) - bStrokes(j));
        rdmStrokesBraille(j,i) = rdmStrokesBraille(i,j);

    end
end

% Save everything for R visualization
writematrix(rdmNbFrench, 'reports/rdm_number_french.csv')
writematrix(rdmPosFrench, 'reports/rdm_position_french.csv')
writematrix(rdmNbBraille, 'reports/rdm_number_braille.csv')
writematrix(rdmPosBraille, 'reports/rdm_position_braille.csv')

writematrix(rdmStrokesFrench, 'reports/rdm_strokes_french.csv')
writematrix(rdmStrokesBraille, 'reports/rdm_strokes_braille.csv')

writematrix(rdmAvgStrokeFrench, 'reports/rdm_avgstroke_french.csv')
writematrix(rdmAvgStrokeBraille, 'reports/rdm_avgstroke_braille.csv')



% Save the table to a csv
writetable(pixels, 'reports/stimuli_pixel_information.tsv', 'FileType', 'text', 'Delimiter', '\t', 'WriteVariableNames', true);



%% Support functions


function number = getNumberStrokes(stringIn, falsefont)

letters = ['a';'b';'c';'d';'e';'f';'g';'h';'i';'j';'k';'l';'m';'n';'o';'p';'q';'r';'s';'t';'u';'v';'w';'x';'y';'z';'é'];
strokes = [ 2;  2;  1;  2;  1;  2;  2;  2;  1;  1;  3;  1;  3;  2;  1;  2;  2;  2;  1;  2;  2;  2;  4;  2;  2;  3;  2];

false_letters = ['b';'c';'d';'f';'g';'h';'j';'k';'l';'m';'n';'p';'q';'r';'s';'t';'v';'w';'x';'y';'z'];
false_strokes = [ 3;  2;  3;  2;  3;  2;  2;  4;  2;  3;  2;  2;  2;  2;  2;  2;  3;  4;  3;  3;  4];

total = 0;

for iC = 1:length(stringIn)
    
    if ~falsefont
        % total number = previous total + number of strokes for that letter
        total = total + strokes(find(letters == stringIn(iC)));
    else
        total = total + false_strokes(find(false_letters == stringIn(iC)));
    end


end

number = total;

end


function number = getNumberDots(stringIn)

letters = ['a';'b';'c';'d';'e';'f';'g';'h';'i';'j';'k';'l';'m';'n';'o';'p';'q';'r';'s';'t';'u';'v';'w';'x';'y';'z';'é'];
dots = [    1;  2;  2;  3;  2;  3;  4;  3;  2;  3;  2;  3;  3;  4;  3;  4;  5;  4;  3;  4;  3;  4;  4;  4;  5;  4;  6];

total = 0;

for iC = 1:length(stringIn)
    
    % total number = previous total + number of dots for that letter
    total = total + dots(find(letters == stringIn(iC)));

end

number = total;

end