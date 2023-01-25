function [output,state]=generateSamples(input,state,param)

bits = input ;
Mod_Type=param.moduType;
Fs=param.Fs;
Rs=param.Rs;
SPS=param.SPS;
SNR=param.SNR;
n_ISI = param.N_ISI;
rolloff=param.rolloff;
Fc=param.Fc;
switch Mod_Type
    case 1                      % 'BPSK'
        modOrder       = 2;
        Symbol_idx=binaryVectorToDecimal(vec2mat(bits,log2(modOrder)));
        Samples_BPSK   = exp(1j*(2*pi*(0:1)/2)).';
        Symbols        = Samples_BPSK(Symbol_idx);
        
    case 2                      % 'QPSK'
        modOrder       = 4;
        tmp=vec2mat(bits,log2(modOrder));
        Symbol_idx=tmp(:,1)*2+tmp(:,2)+1;
        Samples_QPSK   = exp(1j*(2*pi*(0:3)/4+pi/4)).';
        Symbols        = Samples_QPSK(Symbol_idx);
        
    case 3                      % '8PSK'
        modOrder       = 8;
        Symbol_idx=binaryVectorToDecimal(vec2mat(bits,log2(modOrder)))+1;
        Samples_8PSK   = exp(1j*(2*pi*(0:7)/8+pi/8)).';
        Symbols        = Samples_8PSK(Symbol_idx);
        
    case 4                      % '16APSK'
        gamma          = 2.75;
        r2             = 1;
        r1             = r2/gamma;
        modOrder       = 16 ;
        Symbol_idx=binaryVectorToDecimal(vec2mat(bits,log2(modOrder)))+1;
        Samples_QPSK   = exp(1j*(2*pi*(0:3 )/4 +pi/4 )).';
        Samples_12PSK  = exp(1j*(2*pi*(0:11)/12+pi/12)).';
        Samples_16APSK = [r1*Samples_QPSK ; r2*Samples_12PSK] ;
        Symbols        = Samples_16APSK(Symbol_idx);
        
    case 5                      % '32APSK'
        gamma2         = 1.54;
        gamma1         = 4.33;
        r3             = 1;
        r2             = r3/gamma2;
        r1             = r3/gamma1;
        modOrder       = 32 ;
        %         Symbol_idx     = randi(modOrder,n_Sym_True,1);
        Symbol_idx=binaryVectorToDecimal(vec2mat(bits,log2(modOrder)))+1;
        Samples_QPSK   = exp(1j*(2*pi*(0:3 )/4 +pi/4 )).' ;
        Samples_12PSK  = exp(1j*(2*pi*(0:11)/12      )).' ;
        Samples_16PSK  = exp(1j*(2*pi*(0:15)/16+pi/16)).' ;
        Samples_32APSK = [r1*Samples_QPSK ; r2*Samples_12PSK ; r3*Samples_16PSK] ;
        Symbols        = Samples_32APSK(Symbol_idx);
        
    case 6                      % '16QAM'
        modOrder = 16 ;
        %         Symbol_idx     = randi(modOrder,n_Sym_True,1);
        Symbol_idx=binaryVectorToDecimal(vec2mat(bits,log2(modOrder)))+1;
        Samples_16QAM  = reshape(repmat(linspace(-1,1,4),4,1),[],1) + 1j*reshape(repmat(linspace(-1,1,4),1,4),[],1) ;
        Symbols        = Samples_16QAM([1*ones(30,1); Symbol_idx; 1*ones(30,1)]);
        
    case 7                      % '64QAM'
        modOrder = 64 ;
        %         Symbol_idx     = randi(modOrder,n_Sym_True,1);
        Symbol_idx=binaryVectorToDecimal(vec2mat(bits,log2(modOrder)));
        Samples_64QAM  = reshape(repmat(linspace(-1,1,8),8,1),[],1) + 1j*reshape(repmat(linspace(-1,1,8),1,8),[],1) ;
        Symbols        = Samples_64QAM([1*ones(30,1); Symbol_idx; 1*ones(30,1)]);
        
    case 8                      % 'OQPSK'
        modOrder       = 4;
        tmp=vec2mat(bits,log2(modOrder));
        Symbol_idx=tmp(:,1)*2+tmp(:,2)+1;
        Samples_OQPSK   = exp(1j*(2*pi*(0:3)/4+pi/4)).';
        Symbols        = Samples_OQPSK(Symbol_idx);
        
    case 41                      % 'pi/2-DBPSK'
        modOrder       = 2;
        Samples_BPSK   = exp(1j*(2*pi*(0:1)/2)).';
        Symbol_idx_1   = randi(modOrder,n_Sym_True/2,1);
        Symbol_idx_2   = randi(modOrder,n_Sym_True/2,1);
        Symbols_1      = Samples_BPSK(Symbol_idx_1);
        Symbols_2      = Samples_BPSK(Symbol_idx_2)*exp(1j*pi/2);
        Symbols        = reshape([Symbols_1 , Symbols_2].' ,[],1) ;
        
    case 42                      % 'pi/4-DQPSK'
        modOrder       = 4;
        Samples_QPSK   = exp(1j*(2*pi*(0:3)/4+pi/4)).';
        Symbol_idx_1   = randi(modOrder,n_Sym_True/2,1);
        Symbol_idx_2   = randi(modOrder,n_Sym_True/2,1);
        Symbols_1      = Samples_QPSK(Symbol_idx_1);
        Symbols_2      = Samples_QPSK(Symbol_idx_2)*exp(1j*pi/4);
        Symbols        = reshape([Symbols_1 , Symbols_2].' ,[],1) ;

    otherwise
        error('invalid Modulation type');
        %         Symbols        = zeros(n_Sym_True+60,1) ;
        
end

n = linspace(-n_ISI/2,n_ISI/2,n_ISI*SPS+1) ;
rrcFilt = zeros(size(n)) ;

for iter = 1:length(n)
    if n(iter) == 0
        rrcFilt(iter) = 1 - rolloff + 4*rolloff/pi ;
        
    elseif abs(n(iter)) == 1/4/rolloff
        rrcFilt(iter) = rolloff/sqrt(2)*((1+2/pi)*sin(pi/4/rolloff)+(1-2/pi)*cos(pi/4/rolloff)) ;
        
    else
        rrcFilt(iter) = (4*rolloff/pi)/(1-(4*rolloff*n(iter)).^2) * (cos((1+rolloff)*pi*n(iter)) + sin((1-rolloff)*pi*n(iter))/(4*rolloff*n(iter))) ;
    end
end
if(isempty(state.zi))
    state.zi=zeros(numel(rrcFilt)-1,1);
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

[Tx_Samples_bb,state.zi] = filter(rrcFilt,1,upsample(Symbols,SPS),state.zi);
nSamp = length(Tx_Samples_bb);

if Mod_Type == 8
    
    Tx_Samples_bb = real(Tx_Samples_bb) + 1j* circshift(imag(Tx_Samples_bb),SPS/2) ;
    buffer_new= imag(Tx_Samples_bb(1:SPS/2));
    Tx_Samples_bb(1:SPS/2)=real(Tx_Samples_bb(1:SPS/2))+1i*state.buffer_oqpsk;
    state.buffer_oqpsk=buffer_new;
end
noiseLog=noise_maker(nSamp,SNR,1,Fs,Rs*(1+rolloff));
Tx_Samples_bb=Tx_Samples_bb+noiseLog;
if Fc == 0
    Tx_Samples_IF = Tx_Samples_bb ;
else
    Tx_Samples_IF = Tx_Samples_bb.*exp(1j*2*pi*(0:length(Tx_Samples_bb)-1)'*Fc/Fs);
end
disp(['SNR = ',num2str(pow2db(1/(std(noiseLog)^2)*(Fs/(Rs*(1+rolloff)))))]);

Rx_Samples_IF = Tx_Samples_IF;
% Rx_Samples_IF = Rx_Samples_IF/max(abs(Rx_Samples_IF)) ;


output=Rx_Samples_IF;