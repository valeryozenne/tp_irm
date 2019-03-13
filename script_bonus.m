
clear all
load('bonus.mat');


%% exercice : extraire le module et la phase de chaque image
%% inverser le module entre les images et/ou inverse la phase et reconstruire les images
%% dire ou se situe kim et ou se situe donald
%% rediger quelques lignes sur l'évolution du demantelement en corée de nord




A = single(rgb2gray(RGB));

% separons l'image en deux
I=A(:,1:size(A,2)/2);
J=A(:,size(A,2)/2+1:end);

% effecttuons la fft

kI=fftshift(fft2(fftshift(I)));
kJ=fftshift(fft2(fftshift(J)));




absI=abs(kI);
phaseI=angle(kI);

absJ=abs(kJ);
phaseJ=angle(kJ);


% close(figure(2))
% figure(2)

clear i

moduleI=abs(kI)
phaseI=angle(kI);
moduleI_original=moduleI;
phaseI_original=phaseI;

moduleJ=abs(kJ);
phaseJ=angle(kJ);
moduleJ_original=moduleJ;
phaseJ_original=phaseJ;

subplot(3,2,1); imagesc(I); colormap(gray);  title('I: kim est ici')
subplot(3,2,2); imagesc(J); colormap(gray);  title('J: donald est ici')

newkI=moduleJ.*exp(1i*phaseI);  
newkJ=moduleI.*exp(1i*phaseJ);  
newI=fftshift(ifft2(fftshift(newkI)));  
newJ=fftshift(ifft2(fftshift(newkJ)));

subplot(3,2,3); imagesc(abs(newI)); colormap(gray);  title('moduleJ -> module I , kim reste ici');
subplot(3,2,4); imagesc(abs(newJ)); colormap(gray);  title('moduleI -> module J , donald reste ici');



newkI=moduleI.*exp(1i*phaseJ);  
newkJ=moduleJ.*exp(1i*phaseI);   

newI=fftshift(ifft2(fftshift(newkI)));  
newJ=fftshift(ifft2(fftshift(newkJ)));

subplot(3,2,5); imagesc(abs(newI)); colormap(gray); title('phaseJ -> phase I , donald arrive ici');
subplot(3,2,6); imagesc(abs(newJ)); colormap(gray); title('phaseJ -> phase I , kim arrive ici');



% pause(0.01)
% end
% for x=1:size(I,1)
%
%     moduleI(1:x,:)=moduleJ_original(1:x,:);
%     moduleJ(1:x,:)=moduleI_original(1:x,:);
% end

%     phaseI(1:x,:)=phaseJ_original(1:x,:);
%     phaseJ(1:x,:)=phaseI_original(1:x,:);
% mid_z=round(size(Data_out,3)/2);
%
%
%
% for te=1:4
% subplot(1,4,te); imagesc(angle(Data_out(:,:,mid_z,te))); colormap(gray);
% end
%
%
%
% close(figure(2))
% figure(2)
%
% for c=1:12
%
% subplot(3,4,c); imagesc(angle(Data_save_echo1(:,:,mid_z/2,c))); colormap(gray);
%
% end
