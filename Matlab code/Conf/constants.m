%%% *********************************************************************
%%% * Batch-service queue model for Blockchain                          *
%%% * By: Lorenza Giupponi & Francesc Wilhelmi (fwilhelmi@cttc.cat)     *
%%% * Copyright (C) 2020-2025, and GNU GPLd, by Francesc Wilhelmi       *
%%% * Repo.: bitbucket.org/francesc_wilhelmi/model_blockchain_delay     *
%%% *********************************************************************

%%% File description: script for storing constants

% Technologies
WIFI = 1;
NR = 2;
% Link types
ACCESS_NETWORK = 1;
P2P_NETWORK = 2;

% Generic PHY modeling constants
CARRIER_FREQUENCY = 5;              % Carrier frequency [GHz] (2.4 or 5) GHz
NOISE_DBM = -95;                    % Ambient noise [dBm]
BANDWITDH_PER_CHANNEL = 20e6;       % Bandwidth per channel in Hz
SINGLE_USER_SPATIAL_STREAMS = 1;    % Number of spatial streams for a single transmission

% Generic MAC modeling constants
PAYLOAD_LENGTH = 12000;             % Payload length in bits
CW_FIXED = 32;                      % CW value used in case of having a fixed exponential backoff procedure
CW_MIN_AP = 8;
CW_MAX_STAGE_AP = 5;
CW_MIN_STA = 32;
CW_MAX_STAGE_STA = 5;
NUM_PACKETS_AGGREGATED = 1;
CCA_THRESHOLD = -82; % Minimum sensitivity (in dBm) to assess signals generating contention

% 802.11ax MAC constants
IEEE_AX_PHY_HE_SU_DURATION = 100e-6;
IEEE_AX_MD_LENGTH = 32;
IEEE_AX_MH_LENGTH = 320;
IEEE_AX_OFDM_SYMBOL_GI32_DURATION = 16e-6;
IEEE_AX_MAX_PPDU_DURATION = 5484e-6;

% DCF 
DIFS = 34E-6; 
SIFS = 16E-6;
Te = 9E-6;
% RTS/CTS 
L_RTS = 160;
L_CTS = 112;
% Service Field  
L_SF = 16;
% MPDU Delimiter if PA is used
L_DEL=32;
%MAC Header including FCS
L_MACH = 272;
% Tail bits
L_TAIL = 6;
% ACK/Block ACK
L_BACK = 240;

SUSS = 1;
% Physical Header (HE SU Format)
LEGACY_PHYH = 20E-6;
%HE_PHYH = (16 + SUSS*4)*1E-6;
HE_PHYH = (16 + SUSS*16)*1E-6;
% Duration of OFDM symbol (CP of 3.2us is included)
T_OFDM = 4E-6;

% MCS indexes
MODULATION_FORBIDDEN = 0;
MODULATION_BPSK_1_2 = 1;
MODULATION_QPSK_1_2 = 2;
MODULATION_QPSK_3_4 = 3;
MODULATION_16QAM_1_2 = 4;
MODULATION_16QAM_3_4 = 5;
MODULATION_64QAM_2_3 = 6;
MODULATION_64QAM_3_4 = 7;
MODULATION_64QAM_5_6 = 8;
MODULATION_256QAM_3_4 = 9;
MODULATION_256QAM_5_6 = 10;
MODULATION_1024QAM_3_4 = 11;
MODULATION_1024QAM_5_6 = 12;

% Throughput calculation mode
WIFI_COMMON = 0;
WIFI_AP_MESH = 1;
NR_SCHEDULED = 2;
NR_P2P = 3;
NR_X2 = 4;
NR_SIDELINK = 5;

% Types of transactions in the blockchain
TRANSACTION_REQUEST_SERVICE = 1;
TRANSACTION_SERVICE_DELIVERY = 2;

% Types of events in the simulation
EVENT_NEW_SERVICE_REQUEST = 1;
EVENT_TRANSACTION_PROPAGATED = 2;
EVENT_BLOCK_MINED = 3;
EVENT_MINED_BLOCK_PROPAGATED = 4;
EVENT_SERVICE_FINISHED = 5;
EVENT_BLOCK_TIMEOUT = 6;
EVENT_START_MINING = 7;

% Logs
LOGS_LVL0 = ' ';
LOGS_LVL1 = '    - ';
LOGS_LVL2 = '       + ';
LOGS_LVL3 = '           * ';
LOGS_LVL4 = '           	. ';
LOGS_LVL5 = '           		> ';

% Other
UNDEFINED = -1;

if not(isfolder('tmp'))
    mkdir('tmp')
end
save('./tmp/constants.mat');              % Save constants into the current folder