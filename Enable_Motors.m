%This is the code for enabling motors via CAN and setting their state to position
%mode. It is assumed motors 1,2,3,4 and 5 are connected to channel one of CAN
%device. Motors 6,7,8,9,19 are connected to channel two of CAN device.

clear all
clc

%canTool  Use this command to open GUI for sniffing CAN messages
%canHWInfo Use this command to check CAN hardware that are available

% select can devices from list of available CAN hardware
txCh1 = canChannel('Kvaser','USBcan Light 1',1);
rxCh1 = canChannel('Kvaser','USBcan Light 1',1);
start(txCh1)
%% Clear fault for all motors

% clear fault commands via SDO

for i=1:7
command = sprintf('60%d',i);   %define motor id
clear_fault(i)=canMessage(hex2dec(command),false,8); 
clear_fault(i).Data=[hex2dec('40') hex2dec('41') hex2dec('60') 0 0 0 0 0];
end

% transmit commands
for i=1:7
transmit(txCh1,clear_fault(i))
pause(0.1)
end

%% Start remote nodes via NMT (go to operational mode)

% different commands can be used to set operation mode (pre-op, start, etc). For all of them the
% Cob Id is 0 for all of them in NMT mode. Data has two bytes. First byte is a desired command, one of
% the five following commands can be used
% 80 is pre-operational
% 81 is reset node
% 82 is reset communication
% 01 is start
% 02 is stop
% second byte is node id, can be 0 (all nodes) or a number between 1 to 256.

command='01'; % start command (change if you want different mode)

for i=1:7
data=sprintf('0%d',i);
msg(i)=canMessage(hex2dec('0'),false,2) ;
msg(i).Data=[hex2dec(command) hex2dec(data)];
end

% transmit commands
for i=1:7
transmit(txCh1,msg(i))
pause(0.1)
end

%% Enable all motors

for i=1:7
command = sprintf('022%d',i);    
msg1(i)=canMessage(hex2dec(command),false,2); %switch off
msg1(i).Data=[hex2dec('00') hex2dec('00')]; 
msg2(i)=canMessage(hex2dec(command),false,2); %turn on
msg2(i).Data=[hex2dec('06') hex2dec('00')];
msg3(i)=canMessage(hex2dec(command),false,2); %enable
msg3(i).Data=[hex2dec('0F') hex2dec('00')]; 
end

transmit(txCh1,msg1(1:7))
pause(0.2)
transmit(txCh1,msg2(1:7))
pause(0.2) 
transmit(txCh1,msg3(1:7))
pause(0.2) 


%% Set all motors to position mode 

% If you want to set the motors to velocity mode change 
% the comand from [hex2dec('0F') hex2dec('0') hex2dec('01')] to
% [hex2dec('0F') hex2dec('0') hex2dec('03')];

for i=1:7
command = sprintf('032%d',i); 
msg(i)=canMessage(hex2dec(command),false,3); 
msg(i).Data=[hex2dec('0F') hex2dec('0') hex2dec('01')];
end

transmit(txCh1,msg(1:7))

%% Define rotational speed of the motor

% Run this only if you want to change the default speed
for i = 1:7
command = sprintf('60%d',i); 
msg11(i)=canMessage(hex2dec(command),false,8); 
%msg11.Data=[hex2dec('22') hex2dec('81') hex2dec('60') 0 hex2dec('E8') hex2dec('03') 0 0]; %1000
%msg11.Data=[hex2dec('22') hex2dec('81') hex2dec('60') 0 hex2dec('32') hex2dec('00') 0 0]; %50
msg11(i).Data=[hex2dec('22') hex2dec('81') hex2dec('60') 0 hex2dec('88') hex2dec('13') 0 0]; %2000
end
msg11(1).Data=[hex2dec('22') hex2dec('81') hex2dec('60') 0 hex2dec('70') hex2dec('17') 0 0]; %2000

transmit(txCh1,msg11(1:7))


%% test by moving one individual motor

% set pos value in inc
% pos= 1*150*4*1024;
% pp=dec2hex(swapbytes(typecast(int32(pos),'uint32')),8);
% p=[hex2dec(pp(1:2)) hex2dec(pp(3:4)) hex2dec(pp(5:6)) hex2dec(pp(7:8))];
%         
% msgg(1)=canMessage(hex2dec('0423'),false,6); %define motor id
% msgg(1).Data=[hex2dec('0F') hex2dec('0') p ];
% 
% transmit(txCh1,msgg)
% 
% pause(2)
% % Toggle new position
% msgg(1)=canMessage(hex2dec('0223'),false,2); %shutdown
% msgg(1).Data=[hex2dec('3F') hex2dec('00')];
% transmit(txCh1,msgg)
% 
% %%
% % pause(2)
% % set pos value
% pos=0;
% pp=dec2hex(swapbytes(typecast(int32(pos),'uint32')),8);
% p=[hex2dec(pp(1:2)) hex2dec(pp(3:4)) hex2dec(pp(5:6)) hex2dec(pp(7:8))];
%         
% msgg(1)=canMessage(hex2dec('0423'),false,6); 
% msgg(1).Data=[hex2dec('0F') hex2dec('0') p ];
% 
% transmit(txCh1,msgg)
% % Toggle new position
% msgg(1)=canMessage(hex2dec('0223'),false,2); %shutdowm
% msgg(1).Data=[hex2dec('3F') hex2dec('00')];
% transmit(txCh1,msgg)
