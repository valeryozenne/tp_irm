%% script
clear all

load('data/kspace_noise.mat');

dataMag=abs(double(reshape(image_multi(:,:,:,:,1),[],1)));
dataReal=real(double(reshape(image_multi(:,:,:,:,1),[],1)));
dataImag=imag(double(reshape(image_multi(:,:,:,:,1),[],1)));

disp(['Real std = ' num2str(std(dataReal))])
disp(['Real std = ' num2str(std(dataImag))])
disp(['Real std = ' num2str(std(dataMag))])
%% tracer un histogram pour chacun
LimMin=10*10^4; %LimMin=100;


figure;

subplot(3,1,1);
h1=histogram(dataReal,50);title('real noise');
xlim([-LimMin LimMin]);

subplot(3,1,2);
h2=histogram(dataImag,50);title('imaginary noise');
xlim([-LimMin LimMin]);

subplot(3,1,3);
h3=histogram(dataMag,50);title('magnitude noise');
xlim([-LimMin LimMin]);


%% Validation des maths
% trouver la valeur de la gaussienne
figure;

subplot(2,1,1);h1=histogram(dataReal,50);title('real noise');
% xlim([-LimMin LimMin]) 

pd = fitdist(dataReal,'Normal')
x_values = pd.mu-4*pd.sigma:8*pd.sigma/1000:pd.mu+4*pd.sigma;
%y = pdf(pd,x_values);
y=1/(pd.sigma*sqrt(2*pi))*exp(-1/2*((x_values-pd.mu)/pd.sigma).^2);
y=y/max(y); y=y*max(h1.Values);
hold on
plot(x_values,y,'LineWidth',2)


subplot(2,1,2);h2=histogram(dataImag,50);title('imag noise');
% xlim([-LimMin LimMin]);
% fit de la distribution real

pd = fitdist(dataImag,'Normal')
x_values = pd.mu-4*pd.sigma:8*pd.sigma/1000:pd.mu+4*pd.sigma;
y = pdf(pd,x_values);
y=y/max(y); y=y*max(h2.Values);
hold on
plot(x_values,y,'LineWidth',2)

%% Ok ca a l'air d'?tre une gaussienne
% est-ce que l'on peut trouver ? partir de la std la distribution dans la
% magnitude

% A partir de l'image magnitude la std de la gaussienne est donc de
% 0.655*std_noise_magnitude

std2= std(dataMag(:))/0.655
pd.sigma

figure; h3=histogram(dataMag,50);title('Magnitude noise');
% xlim([-LimMin LimMin]);
% Rician distribution ( SNR = 0 -> Rayleigh distribution)
x=0:LimMin/1000:LimMin;
y=x./pd.sigma^2.*exp(-x.^2/(2*pd.sigma^2));
y=y/max(y); y=y*max(h3.Values);
hold on
plot(x,y,'LineWidth',2)


%% ajout cas 4 canaux
% nouvelle m?thode de mesure std

Nc=1
sqrt(sum(dataMag(:).^2)/(Nc*2*length(dataMag(:))))

%% 
figure;
A=0;
for i=1:4
    dataMagMc=squeeze(sqrt(sum(abs(double(image_multi(:,:,:,:,1:i))).^2,5)));
    subplot(4,1,i);h1=histogram(dataMagMc,50);title(['noise for ' num2str(i) ' channels']);
%     xlim([-LimMin LimMin]);
    
    x=0:LimMin/1000:LimMin;

    % suppresion de A
    y=(x.^i)./pd.sigma^2.*exp(-(x.^2)./(2*pd.sigma^2)).*besseli(i-1,x/pd.sigma^2);
    y=y/max(y); y=y*max(h1.Values);
    hold on
    plot(x,y,'LineWidth',2);
    
    % Equation avec d?veloppement de taylor
    y2=(x.^(2*i-1))./(2^(i-1)*pd.sigma^(2*i)*factorial(i-1)).*exp(-(x.^2)./(2*pd.sigma^2));
    y2=y2/max(y2); y2=y2*max(h1.Values);
    hold on
    plot(x,y2,'--','LineWidth',2);
end


% pd = fitdist(dataReal,'Normal')
% x_values = pd.mu-4*pd.sigma:8*pd.sigma/1000:pd.mu+4*pd.sigma;
% %y = pdf(pd,x_values);
% y=1/(pd.sigma*sqrt(2*pi))*exp(-1/2*((x_values-pd.mu)/pd.sigma).^2)
% y=y/max(y); y=y*max(h1.Values);
% hold on
% plot(x_values,y,'LineWidth',2)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Noise correlation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Mesurer Noise covariance
% eta: [ncoils,Nsamples]

eta=reshape(image_multi,[],4);
eta=eta';

Nsamples=size(eta,2);

Psi = (1/(Nsamples-1))*(eta * eta');
figure;imagesc(abs(Psi));

    %% Noise pre-whitening
% eta: [ncoils,Nsamples]
% Psi: [ncoils,Nsamples]
% data: [ncoils,Nsamples]

L=chol(Psi,'lower');
L_inv=inv(L);

data=L_inv*eta;

%% 
LimMin=10;
data=data; 

% cas 2
% LimMin=10*100;
% data=data*100; 

dataRealCor=real(double(data(1,:)'));
dataImagCor=imag(double(data(1,:)'));
dataMagCor=abs(double(data(1,:)'));

figure;

subplot(2,1,1);h1=histogram(dataRealCor,50);title('real noise');
xlim([-LimMin LimMin]) 

pd = fitdist(dataRealCor,'Normal')
x_values = pd.mu-4*pd.sigma:8*pd.sigma/1000:pd.mu+4*pd.sigma;
%y = pdf(pd,x_values);
y=1/(pd.sigma*sqrt(2*pi))*exp(-1/2*((x_values-pd.mu)/pd.sigma).^2);
y=y/max(y); y=y*max(h1.Values);
hold on
plot(x_values,y,'LineWidth',2)


subplot(2,1,2);h2=histogram(dataImagCor,50);title('imag noise');
xlim([-LimMin LimMin]);
% fit de la distribution real

pd = fitdist(dataImagCor,'Normal')
x_values = pd.mu-4*pd.sigma:8*pd.sigma/1000:pd.mu+4*pd.sigma;
y = pdf(pd,x_values);
y=y/max(y); y=y*max(h2.Values);
hold on
plot(x_values,y,'LineWidth',2)

%%
figure;
A=0;
for i=1:4
    dataMagMc=squeeze(sqrt(sum(abs(double(data(1:i,:)')).^2,2)));
    subplot(4,1,i);h1=histogram(dataMagMc,50);title(['noise for ' num2str(i) ' channels']);
    
   
    xlim([-LimMin LimMin]);
    
    x=0:LimMin/1000:LimMin;

    % suppresion de A
    y=(x.^i)./pd.sigma^2.*exp(-(x.^2)./(2*pd.sigma^2)).*besseli(i-1,x/pd.sigma^2);
    y=y/max(y); y=y*max(h1.Values);
    hold on
    plot(x,y,'LineWidth',2); %legend('bessel')
    
    % Equation avec d?veloppement de taylor
    y2=(x.^(2*i-1))./(2^(i-1)*pd.sigma^(2*i)*factorial(i-1)).*exp(-(x.^2)./(2*pd.sigma^2));
    y2=y2/max(y2); y2=y2*max(h1.Values);
    hold on
    plot(x,y2,'--','LineWidth',2);
end

% explication diff?rence entre les 2 m?thodes ??? modification ?tendu
% signal
