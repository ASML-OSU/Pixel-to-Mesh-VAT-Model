function resultant_reaction_force = read_reaction_force_nodes(pchfname)
 
resultant_reaction_force = 1e-10;
 
 
% Check if the file exists
fid = fopen(pchfname);
if fid > 0
    disp('Buckling analysis pch file exists');
    fclose(fid);
else
    disp('Buckling analysis pch file DOES NOT exist');
    return;  % Exit the function if the file doesn't exist
end
 
% Open the .pch file for reading
fileID = fopen(pchfname, 'r');
 
% Check if the file is opened successfully
if fileID > 0
    disp('Buckling analysis pch file opened successfully');
else
    disp('Error: Unable to open the pch file');
    return;
end
 
% Initialize a cell array to store numerical values from each line
numericalValues = {};
 
% Flag to indicate whether to start reading lines
startReading = false;
 
% Regular expression pattern to match numerical values (float or scientific notation)
pattern = '[-+]?\d*\.?\d+([eE][-+]?\d+)?';
 
% Initialize variables
success = false;
 
% Keep trying until success or end of file
while ~success && ~feof(fileID)
    try
        % Your code here
        tline = fgetl(fileID);
        startReading = false;  % Initialize the flag
 
        while ischar(tline)
            % Check if the line is not empty and contains "$SUBCASE ID = 1"
            if ~isempty(tline) && contains(tline, '$SUBCASE ID =           1')
                % Set the flag to start reading lines
                startReading = true;
                % Read the next line
                tline = fgetl(fileID);
                continue; % Skip the line containing "$SUBCASE ID = 1"
            end
 
            % If the flag is set, extract numerical values from the line
            if startReading
                % Split the line into numerical values using regular expression
                values = regexp(tline, pattern, 'match');
                % Convert extracted values to numbers and store in the cell array
                numericalValues{end + 1} = str2double(values);
            end
 
            % Read the next line
            tline = fgetl(fileID);
        end
 
        % Set success to true if the code executes without errors
        success = true;
    catch ex
        % If an error occurs, display the error message and try again
        warning('Error occurred: %s. Retrying...', ex.message);
    end
end
 
% Close the file
fclose(fileID);
 
% Determine the maximum number of columns in the data
maxCols = max(cellfun(@length, numericalValues));
 
% Pad shorter lines with NaN values to make all lines have the same length
numericalMatrix = cell2mat(cellfun(@(x) [x, NaN(1, maxCols - length(x))], numericalValues, 'UniformOutput', false))';
 
% Remove rows with all NaN values
numericalMatrix = numericalMatrix(~all(isnan(numericalMatrix), 2), :);
 
% Check if the length of numericalMatrix is a multiple of 9
if mod(length(numericalMatrix), 9) ~= 0
    error('Error: The length of numericalMatrix should be a multiple of 9.');
else
    % Reshape numericalMatrix into a 2D matrix where each row contains 9 elements
    reactionforceMatrix = reshape(numericalMatrix, 9, []).';
end
 
% Display the reshaped matrix
% disp(reactionforceMatrix);
 
% Delete the fifth and ninth columns
reactionforceMatrix(:, 3:9) = [];
reactionforceMatrix(:, 1) = [];
 
% Rows to sum
rowsToSum = [25,      50,      75,      100,     125,     150, ...
175,     200,     225,     250,     275,     300,     325,     350, ...
375,     400,     425,     450,     475,     500,     525,     550, ...
575,     600,     625]; %Replace the current RHS nodes
 
% Sum the specified rows
resultant_reaction_force = sum(reactionforceMatrix(rowsToSum));
 
end