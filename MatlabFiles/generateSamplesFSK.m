function [output,state]=generateSamplesFSK(input,state,param)
global H;
bits = input ;
Mod_Type=param.moduType;
Fs=param.Fs;
Rs=param.Rs;
SPS=param.SPS;
SNR=param.SNR;
Fc=param.Fc;
modu_ind=param.moduInd;
firstTime=param.firstTime;
switch Mod_Type
    case 1                      % '2FSK'
        modOrder       = 2;
        FrequencySeparation=modu_ind*Fs/SPS;
        Symbol_idx=bits;
        if(firstTime)
            H = comm.FSKModulator('ModulationOrder',modOrder,'FrequencySeparation',FrequencySeparation,'SamplesPerSymbol',SPS,'SymbolRate',Fs/SPS,'ContinuousPhase',true);
        end
        samples = step(H,Symbol_idx);
        samples = samples(:);
        %         save('MatObj.mat','H');

    case 2                      % '4FSK'
        modOrder       = 4;
        FrequencySeparation=(modu_ind/2)*Fs/SPS;
        tmp=vec2mat(bits,log2(modOrder));
        Symbol_idx=tmp(:,1)*2+tmp(:,2);
        if(firstTime)
            H = comm.FSKModulator('ModulationOrder',modOrder,'FrequencySeparation',FrequencySeparation,'SamplesPerSymbol',SPS,'SymbolRate',Fs/SPS,'ContinuousPhase',true);
        end
        samples = step(H,Symbol_idx);
        samples = samples(:);

    case 3                      % 'MSK'
        FrequencySeparation=(0.5)*Fs/SPS;
        modOrder       = 2;
        Symbol_idx=bits;
        if(firstTime)
            H = comm.FSKModulator('ModulationOrder',2,'FrequencySeparation',FrequencySeparation,'SamplesPerSymbol',SPS,'SymbolRate',Fs/SPS,'ContinuousPhase',true);
        end
        samples = step(H,Symbol_idx);
        samples = samples(:);


    otherwise
        error('invalid Modulation type');
        %         Symbols        = zeros(n_Sym_True+60,1) ;

end


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
Tx_Samples_bb=samples;
nSamp = length(Tx_Samples_bb);
noiseLog=noise_maker(nSamp,SNR,1,Fs,Rs);
Tx_Samples_bb=Tx_Samples_bb+noiseLog;

disp(['SNR = ',num2str(pow2db(1/(std(noiseLog)^2)*(Fs/Rs)))]);

output = Tx_Samples_bb;


