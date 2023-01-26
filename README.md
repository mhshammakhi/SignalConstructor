# SignalConstructor

In this project we will upload Matlab version, Python version, and C++ version of Signal constructor
The matlab version was uploaded and the c++ version has been completed. It will be uploaded soon.
If we find any support or order for CUDA version, we will develop it.

- [x] Matlab Version
- [ ] C++ Version
- [ ] Python Version
- [ ] CUDA Version


## Matlab Code

The Matlab code contains some functions: You can run the signal generator by using 'main.m' script. In 'generateBitStream.m' we generate bit stream for transmitting. You can create any other frame structure by changing this file. In our proposed structure the generate frames have some parts:
  - HeaderSync
  - Scrambler number
  - Frame number
  - Payload
  - Footer
  
Header Sync is 'FEEFABCDFCCF' and the footer is 'ABCD'. The frame number repeat 2 times in the frame and the scrambler number is repeated six times. The payload length is 2^16 and it is the 16-bit counter.

Now it is time to say what is scrambler number. If we repeat the desired frames, it will affect on the spectrum of signal because of reputation. So I scramble the payload with the sequence. we recorded the sequence and for each frame, we use one of them and we put the sequence number in the frame for the receiver side to export the correct bits. the recorded sequences can be found in 'scramblerVecs.mat'. 
'generateSamples.m' prepares samples and symbols from generated bits.
this function contains symbol mapping, pulse shaping, frequency modulation (LO), and channel effect processing block (add noise for AWGN)

  
  
  
  
  
