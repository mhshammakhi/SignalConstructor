function output=noise_maker(N,SNR,signal_power,Fs,BW)

output = sqrt(Fs/BW)*10^(-SNR/20)*(randn(N,1)+1j*randn(N,1))/sqrt(2)*sqrt(signal_power);