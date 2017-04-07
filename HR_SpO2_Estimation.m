%% Estimation of SpO2 level and heart rate using PPG data. PPG is measured
%% while the object stay still so no moving artifact involves. 940nm/ 660nm
%Created by: Thinh Nguyen 
%Email: mecheng.hn@gmail.com
%Date: 2015 April

% THIS ONE IS NOT OPTIMIZED. DO NOT USE FOR COMMERCIAL

%% START
clear all
[X1,X2]=textread('PPG.dat','%s %s');

for i=1:length(X1)
    X(i,1)=hex2dec(X1(i));
    if X(i,1)> hex2dec('7FFFFF')   %Dont pay attention to this part. It is the conversion of acquired HEX value into useful decimal value
        X(i,1)=hex2dec('7FFFFF') - X(i,1);
    end
    X(i,2)=hex2dec(X2(i)); 
    if X(i,2)> hex2dec('7FFFFF')
        X(i,2)=hex2dec('7FFFFF')- X(i,2);
    end
end

plot(X(:,1))
hold on
plot(X(:,2),'r')

fs=25; %sampling rate 15Hz
FFT_size=128; %default: 64


%% Data frame
for n=1:fix((length(X)/(2*fs))-2)
y1=X(n*fs:(n*fs+FFT_size-1),1); %RED
y2=X(n*fs:(n*fs+FFT_size-1),2); %IR

%% FFT Transform RED
NFFT = FFT_size ; % Next power of 2 from length of y
Y1 = fft(y1,NFFT);
f1 = fs/2*linspace(0,1,NFFT/2+1);

figure(1)
plot(f1,abs(Y1(1:NFFT/2+1)));
axis([0.5 2.5 0 3e5])

%% FFT Transform IR
NFFT = FFT_size; % Next power of 2 from length of y
Y2 = fft(y2,NFFT);
f2 = fs/2*linspace(0,1,NFFT/2+1);

figure(2)
plot(f2,abs(Y2(1:NFFT/2+1)));
axis([0.5 2.5 0 2e5])
hold on

%% Find local maximum in RED spectrum

YY=abs(Y1(6:12));
local_max_i=1;
local_max=YY(1);
for i=2:(length(YY)-1)
    if local_max<(YY(i))
        local_max_i=i;
        local_max=YY(i);
    end    
end
pk_RED_i=6-1+local_max_i;

%% Find local maximum in IR spectrum

YY=abs(Y2(6:12));
local_max_i=1;
local_max=YY(1);
for i=2:(length(YY)-1)
    if local_max<(YY(i))
        local_max_i=i;
        local_max=YY(i);
    end    
end
pk_IR_i=6-1+local_max_i;

%% Heart rate
HEART_RATE(n) = f2(pk_IR_i)*60  %%In fact, using FFT limits the accuracy of heart rate estimation. See the points on f1/ f2 arrays and you know why. I wrote a peak detection algorithm for heart rate only. See the second .m file. 

%% SpO2 
R_RED = abs(Y1(pk_RED_i)/abs(Y1(1)));
R_IR = abs(Y2(pk_IR_i)/abs(Y2(1)));
R=R_RED/R_IR;
SpO2(n) = 104 - 28*R

end

%% Take average value of heart rate and SpO2
HR=sum(HEART_RATE(2:(length(HEART_RATE)-1)))/(length(HEART_RATE)-2);
S=sum(SpO2(2:(length(SpO2)-1)))/(length(SpO2)-2);
Heart_Rate=round(HR)
SpO2_Level=round(S)

% %% Plot result
% y1=X(:,1);
% y2=X(:,2);
% 
% % Denoising
% for i=1:(length(y1)-1)
%     if ((y1(i+1)-y1(i))>50000)
%         y1(i+1)=y1(i+1)+ 65100;
%     elseif ((y1(i)-y1(i+1))>50000)
%         y1(i+1)=y1(i+1)+65100;
%     end
% end
% 
% for i=1:(length(y2)-1)
%     if ((y2(i+1)-y2(i))>50000)
%         y2(i+1)=y2(i+1)+ 65100;
%     elseif ((y2(i)-y2(i+1))>50000)
%         y2(i+1)=y2(i+1)+65100;
%     end
% end
% 
% x=0:1:length(y1)-1;
% plot(x,y1+3e5,'r');
% hold on
% plot(x,y2,'b');
% legend('RED','IR');
% legend('boxoff');
% str1 = ['Heart rate = ',num2str(HR)];
% text(length(y2)/2,max(y2)*4/5,str1);

%% END





