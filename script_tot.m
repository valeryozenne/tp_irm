%% Script TP_IRM
clear all;
close all;
load('data/kspace_brain_1ch.mat');

im_1ch = fftshift(ifft2(fftshift(kspace_1ch)));

% Un ?cho correspond ? 1 ligne
figure;subplot(3,1,1);plot(abs(kspace_1ch(:,end/2)));
subplot(3,1,2);plot(fftshift(abs(kspace_1ch(:,end/2))));

profil=abs(fftshift(ifft(fftshift((kspace_1ch(:,end/2))))));
profil2=sum(abs(im_1ch),2);
subplot(3,1,3);plot(profil);hold on;plot(profil2);

% la fft de la ligne central correspond 
% ? la somme du signal dans l'image perpendiculairement ? cette ligne
% (explication avec schema physique selon la fr?quence)

figure;
subplot(3,1,1); imshow(abs(kspace_1ch),[0 0.05*max(abs(kspace_1ch(:)))]);
subplot(3,1,2); imshow(real(im_1ch),[]);
subplot(3,1,3); imshow(imag(im_1ch),[]);

% Calculer le module et la phase de l'image et l'afficher
figure;
subplot(1,2,1); imshow(abs(im_1ch),[]);
subplot(1,2,2); imshow(angle(im_1ch),[]);


% Pourquoi le fftshift 
figure;imshow(fftshift(abs(im_1ch)),[]);

%% Jouer avec le kspace

sx=size(kspace_1ch,1);
sy=size(kspace_1ch,2);

% Enlever le centre
NbPointRet=10; % Param ? jouer

kSansCentre = kspace_1ch;
kSansCentre(sx/2+1-NbPointRet:sx/2+NbPointRet,sy/2+1-NbPointRet:sy/2+NbPointRet)=0;

imSansCentre=fftshift(ifft2(fftshift(kSansCentre)));

% Enlever les bords
kAvecCentre = kspace_1ch;
kAvecCentre([1:sx/2+1-NbPointRet sx/2+NbPointRet:end],[1:sy/2+1-NbPointRet sy/2+NbPointRet:end])=0;

imAvecCentre=fftshift(ifft2(fftshift(kAvecCentre)));

figure;
subplot(1,2,1);imshow(abs(imSansCentre),[]); title('Sans centre');
subplot(1,2,2);imshow(abs(imAvecCentre),[]); title('Avec centre');



% zero filling

kZeroF=zeros(2*sx,2*sy);
kZeroF(sx/2+1:sx*3/2,sy/2+1:sy*3/2)=kspace_1ch;

figure;
subplot(1,2,1); imshow(abs(fftshift(ifft2(fftshift(kZeroF)))),[]);
subplot(1,2,2); imshow(abs(fftshift(ifft2(fftshift(kspace_1ch)))),[]);



% Ajout point avec 10000 en intensit?
%%
load('data/tmp/brain_8ch.mat');

im1ch=im(:,:,1);


%Reco sum of square
imSOS=sqrt(sum(abs(im).^2,3));

%im 2 kspace
for i=1:8
    kspace_8ch(:,:,i)=fftshift(fft2(fftshift(im(:,:,i))));
end

kspace=fftshift(ifft2(imSOS));

%modif kspace 1
kspace1=kspace;
kspace1(70,60)=kspace1(70,60)*200;
imModif1=fft2(kspace1);

%modif kspace 2
kspace2=kspace;
kspace2(70,130)=kspace2(70,130)*200;
imModif2=fft2(kspace2);

% affichage

fig=figure; 

subplot(3,3,2); imshow(abs(kspace));

subplot(3,3,4); imshow(abs(kspace),[]);
subplot(3,3,5); imshow(abs(kspace1),[]);
subplot(3,3,6); imshow(abs(kspace2),[]);

subplot(3,3,7); imshow(abs(imSOS),[]);
subplot(3,3,8); imshow(abs(imModif1),[]);
subplot(3,3,9); imshow(abs(imModif2),[]);


kspace_new=complex(zeros(size(kspace)));

kspace_new1=kspace_new;
kspace_new1(60,80)=200+ i*200;
imModif1=fft2(kspace_new1);

kspace_new2=kspace_new;
kspace_new2(10,10)=200+ i*200;
imModif2=fft2(kspace_new2);

%% Effet d'un gradient sur le mouvement dans l'image

FOV = 200;
offset=30;
sx = size(kspace,1);
sy = size(kspace,2);

phaseOffy=zeros(sx,sy);
for k=1:sy
    phaseOffy(:,k)=ones(sx,1)*(k-sy/2+1)/sy*sy*offset/FOV;
end

phaseOff=exp(1i*2*pi*phaseOffy);

kspaceOff=kspace.*phaseOff;

imOff=abs(ifft2(kspaceOff));
imSOS=abs(ifft2(kspace));
figure;subplot(1,2,1);imshow(imSOS,[]);
subplot(1,2,2);imshow(imOff,[]);


%% Bruit

% pr?senter les maths
%% Cours SENSE

