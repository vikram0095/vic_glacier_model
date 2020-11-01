function [to]=readRoutMonth(filename)
fid = fopen(filename,'r');
count=1;
tline = fgetl(fid);
to(count,:)=textscan(regexprep(tline,' +',' '),'%d %d %f');
while ~feof(fid)
    tline = fgetl(fid);
    count=count+1;
    tempo=regexprep(tline,' +',' ');
    to(count,:)=textscan(tempo,'%d %d %f');
end
fclose(fid);

end