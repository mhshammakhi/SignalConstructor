function param=writeToFile(fileID,samples,seekSample,param)
type=param.type;

tmp=[real(samples),imag(samples)];
tmp=tmp.';
file_data=tmp(:);
if(strcmp(type,'float'))
    fseek(fileID, seekSample*4*2, 'bof');
    fwrite(fileID,file_data,'float') ;
elseif(strcmp(type,'int16'))
    maxfile_data=max(abs(file_data));
    param.maxLast=max(param.maxLast,maxfile_data);

    fseek(fileID, seekSample*2*2, 'bof');
    fwrite(fileID,floor(file_data/param.maxLast*(2^15-1)),'int16') ;
else
    error('Type of File invalid !!!');
end


