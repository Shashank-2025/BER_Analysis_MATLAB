% BER Analysis of BPSK, QPSK and 16-QAM in AWGN Channel
% Author: Vicky (ECE Student)

clc; clear; close all;

N = 1e5;                      % Number of bits
SNRdB = 0:2:20;               % SNR range
BER_bpsk = zeros(size(SNRdB));
BER_qpsk = zeros(size(SNRdB));
BER_qam16 = zeros(size(SNRdB));

bits = randi([0 1], N, 1);    % Generate random bits

%% ---------- BPSK ----------
bpsk_mod = 2*bits - 1;        % BPSK mapping (0→-1, 1→+1)

for i = 1:length(SNRdB)
    rx = awgn(bpsk_mod, SNRdB(i), 'measured');
    bpsk_demod = rx > 0;
    BER_bpsk(i) = sum(bits ~= bpsk_demod) / N;
end

%% ---------- QPSK ----------
% Group bits in pairs → symbols
bit_pairs = reshape(bits(1:2*floor(N/2)), 2, []).';
qpsk_mod = pskmod(bin2dec(num2str(bit_pairs)), 4, pi/4);

for i = 1:length(SNRdB)
    rx = awgn(qpsk_mod, SNRdB(i), 'measured');
    qpsk_demod = pskdemod(rx, 4, pi/4);
    qpsk_bits = de2bi(qpsk_demod, 2);
    qpsk_bits = qpsk_bits(:);
    BER_qpsk(i) = sum(bits(1:length(qpsk_bits)) ~= qpsk_bits) / length(qpsk_bits);
end

%% ---------- 16-QAM ----------
qam16_mod = qammod(bits(1:log2(16)*floor(N/log2(16))), 16, 'bin');
for i = 1:length(SNRdB)
    rx = awgn(qam16_mod, SNRdB(i), 'measured');
    qam16_demod = qamdemod(rx, 16, 'bin');
    qam16_bits = de2bi(qam16_demod, 4);
    qam16_bits = qam16_bits(:);
    BER_qam16(i) = sum(bits(1:length(qam16_bits)) ~= qam16_bits) / length(qam16_bits);
end

%% ---------- PLOT ----------
figure;
semilogy(SNRdB, BER_bpsk, '-o', 'LineWidth', 2); hold on;
semilogy(SNRdB, BER_qpsk, '-s', 'LineWidth', 2);
semilogy(SNRdB, BER_qam16, '-^', 'LineWidth', 2);

grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('BER Performance of BPSK, QPSK, and 16-QAM in AWGN Channel');
legend('BPSK', 'QPSK', '16-QAM');
