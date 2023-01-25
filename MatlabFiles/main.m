clc;clear;close all;
param.SPS=2;
param.SNR=14;
offset=0*0.1;

modu_ind=1; %For FSK

nSymbol=10;
nSample=nSymbol*param.SPS;
chankSizeSample=1e4;

nframe=ceil(nSample/chankSizeSample);
nSymbolPerFrame=ceil(chankSizeSample/param.SPS);
bufferBit=[];

frameBitSize=1048680;
seekSample=0;
%%
param.Fs       = param.SPS*1e6   ;
%%
%%
choiceFamily = menu('Modulation Family','PSK','FSK','ASK');
switch choiceFamily
    case 1
        param.Family='PSK';
        moduVector={'BPSK','QPSK','8PSK','16APSK','32APSK','16QAM','64QAM','OQPSK'};
        modOrderVec=[1,2,3,4,5,4,6,2];
        moduType = menu('Modulation:','BPSK','QPSK','8PSK','16APSK','32APSK','16QAM','64QAM','OQPSK');
        param.moduTypeStr=moduVector{moduType};
        param.Modorder=modOrderVec(moduType);
        param.moduType=moduType;
        param.Rs= param.Fs/param.SPS;
        param.rolloff=0.25;
        param.N_ISI=100;
        param.Fc= offset*param.Fs;
        param.BW=param.Rs*(1+param.rolloff)/param.Fs;
        disp('Proccessing ...')
        nBitPerFrame=nSymbolPerFrame*param.Modorder;

    case 2
        param.Family='FSK';
        moduVector={'2FSK','4FSK','MSK'};
        modOrderVec=[1,2,1];
        moduType = menu('Modulation:','2FSK','4FSK','MSK');
        param.moduTypeStr=moduVector{moduType};
        param.Modorder=modOrderVec(moduType);
        param.moduType=moduType;
        param.moduInd=1;
        param.Rs= param.Fs/param.SPS;
        param.Fc= offset*param.Fs;
        param.BW=param.Rs/param.Fs;
        param.firstTime=true;
        disp('Proccessing ...')
        nBitPerFrame=nSymbolPerFrame*param.Modorder;

        %         disp('This option is not available!')
        %         return;
    otherwise
        disp('This option is not available!')
        return;
end
%%
choice = menu('Record Type','float','int16','Cancel');
typesOutput={'float','int16'};
tic;
switch choice
    case 1
        if(choiceFamily==1 || strcmp(param.moduTypeStr,'MSK') )
            fileID = fopen(['.\outputSignals\signal','_Fc',num2str(floor(10*offset)),'_SPS',num2str(param.SPS),'_Modu',param.moduTypeStr,'_SNR',num2str(param.SNR),'_float.bin'],'w');
        elseif (choiceFamily==2)
            fileID = fopen(['.\outputSignals\signal','_Fc',num2str(floor(10*offset)),'_SPS',num2str(param.SPS),'_Modu',param.moduTypeStr,'_ModuInd',num2str(param.moduInd),'_SNR',num2str(param.SNR),'_float.bin'],'w');
        end
        %         fwrite(fileID,file_data,'float') ;

    case 2
        if(choiceFamily==1 || strcmp(param.moduTypeStr,'MSK') )
            fileID = fopen(['.\outputSignals\signal','_Fc',num2str(floor(10*offset)),'_SPS',num2str(param.SPS),'_Modu',param.moduTypeStr,'_SNR',num2str(param.SNR),'_int16.bin'],'w');
        elseif (choiceFamily==2)
            fileID = fopen(['.\outputSignals\signal','_Fc',num2str(floor(10*offset)),'_SPS',num2str(param.SPS),'_Modu',param.moduTypeStr,'_ModuInd',num2str(param.moduInd),'_SNR',num2str(param.SNR),'_int16.bin'],'w');
        end

    case 3
        return;
end
toc;

paramWrite.type=typesOutput{choice};
paramWrite.maxLast=0;

%%
switch choiceFamily
    case 1
        states.zi=[];
        states.buffer_oqpsk=zeros(floor(param.SPS/2),1);

        for i=1:nframe
            if(nBitPerFrame>numel(bufferBit))
                newBitNeed=nBitPerFrame-numel(bufferBit);
                bufferBit=[bufferBit;generateBitStream(ceil(newBitNeed/frameBitSize))];
            end
            [samples,states]=generateSamples(bufferBit(1:nBitPerFrame),states,param);
            bufferBit(1:nBitPerFrame)=[];
            paramWrite=writeToFile(fileID,samples,seekSample,paramWrite);
            %                 param=writeToFile(fileID,samples,seekSample,param)
            %                 run writeToFile.m;
            seekSample=seekSample+numel(samples);
            disp([num2str(seekSample),'/',num2str(nSample),' Samples have been Generated ...']);
            if(seekSample>nSample)
                break;
            end
        end

    case 2
        global H;
        for i=1:nframe
            if(nBitPerFrame>numel(bufferBit))
                newBitNeed=nBitPerFrame-numel(bufferBit);
                bufferBit=[bufferBit;generateBitStream(ceil(newBitNeed/frameBitSize))];
                states=0;
                [samples,states]=generateSamplesFSK(bufferBit(1:nBitPerFrame),states,param);
                bufferBit(1:nBitPerFrame)=[];
                param.firstTime=false;
                paramWrite=writeToFile(fileID,samples,seekSample,paramWrite);
                %                 run writeToFile.m;
                seekSample=seekSample+numel(samples);
                disp([num2str(seekSample),'/',num2str(nSample),' Samples have been Generated ...']);
                if(seekSample>nSample)
                    break;
                end
            end
        end
end
fclose(fileID);
%%
%%



