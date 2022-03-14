t = readtable('cellcom_metadata_20190401.xls');
type = 1;
[M, N] = size(t);
lat1 = zeros(M, 1);
lon1 = zeros(M, 1);
lat2 = zeros(M, 1);
lon2 = zeros(M, 1);

for i = 1:M
    [lat1(i), lon1(i)] = Grid2LatLon(t.EAST1(i), t.NORTH1(i), type);
    [lat2(i), lon2(i)] = Grid2LatLon(t.EAST2(i), t.NORTH2(i), type);
end


% Add a new column to the end of the table
numOfColumn = size(t, 2);
newCol = num2cell(lat1); % Your new column
t.(numOfColumn+1) = newCol;
% Change column name if needed
t.Properties.VariableNames{numOfColumn+1} = 'LAT1';

newCol = num2cell(lon1); % Your new column
t.(numOfColumn+2) = newCol;
% Change column name if needed
t.Properties.VariableNames{numOfColumn+2} = 'LON1';

newCol = num2cell(lat2); % Your new column
t.(numOfColumn+3) = newCol;
% Change column name if needed
t.Properties.VariableNames{numOfColumn+3} = 'LAT2';

newCol = num2cell(lon2); % Your new column
t.(numOfColumn+4) = newCol;
% Change column name if needed
t.Properties.VariableNames{numOfColumn+4} = 'LON2';
% Write to CSV file
writetable(t, 'new_meta_data.xls')

