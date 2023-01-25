function output = generateBitStream(nFrame)

load('scramblerVecs.mat','scramblerMat');
numScr=size(scramblerMat,1);
payload = decimalToBinaryVector(0:(2^16-1),16);
payloadStream=vec2mat(payload,1);
FrameByte=2^16 * 2;

HeaderSync=hexToBinaryVector('FEEFABCDFCCF');
scr_i=randi(numScr,1,nFrame);
output_payload=[];
for i=1:nFrame
    ins_payload=xor(logical(payloadStream'),scramblerMat(scr_i(i),:));
    output_payload=[output_payload;ins_payload];
end
output=[repmat(HeaderSync,nFrame,1),repmat(decimalToBinaryVector(scr_i,4),1,6),repmat(decimalToBinaryVector(mod(0:nFrame-1,256),8),1,2),output_payload,repmat(hexToBinaryVector('ABCD'),nFrame,1)];
output=vec2mat(output,1);

