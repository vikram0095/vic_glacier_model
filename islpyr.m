
function [ status ] = islpyr( year )
if mod(year, 400) == 0
status = true;
elseif mod(year, 4) == 0 && mod(year, 100) ~= 0
status = true;
else
status = false;
end
end
