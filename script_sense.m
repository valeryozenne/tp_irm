%%
% Demo reconstruction sense

%%


close all;
clear all;

addpath('function_ismrmrd');

load('data/kspace_brain_sense.mat');

%  Diminution de la taille de l image
img_originale=imresize(image_brain,0.5);

%  Image de depart

ismrm_imshow(img_originale);
% ismrm_save_image( outputFolder, 'image_depart' );

%  Chargement des cartes de sensibilites


% afficher les cartes de sensibilités module et phase avec la fonction  ismrm_imshow
% ismrm_imshow(abs(smaps),[min(abs(smaps(:))) max(abs(smaps(:)))],[2 4]);
% ismrm_save_image( outputFolder, 'coil_sensitivity_abs' );

% ismrm_imshow(angle(smaps),[min(angle(smaps(:))) max(angle(smaps(:)))],[2 4]);
% ismrm_save_image( outputFolder, 'coil_sensitivity_angle' );

%  Echantillonnage avec 8 antennes et carte de sensiilites
[data_1, sp_1] = ismrm_sample_data(img_originale, smaps, 1);


acc_factor=2;

noise_level = 0.05*max(img_originale(:));
noise_white = noise_level*complex(randn(size(data_1)),randn(size(data_1))) .* repmat(sp_1 > 0,[1 1 size(smaps,3)]);

data_1=data_1+noise_white;

%  Nombres d antennes
nCoils=size(data_1,3);

I_raw_1=ifft_2D(data_1);



% ismrm_imshow(abs(I_raw_1),[0 max(abs(I_raw_1(:)))],[2 4]);
% ismrm_save_image( outputFolder, 'raw_image_abs' );

% ismrm_imshow(angle(I_raw_1),[-pi pi],[2 4]);
% ismrm_save_image( outputFolder, 'raw_image_angle' );

readout=size(img_originale,1);
N=size(img_originale,2);

% ici nous avons le kspace nous réduisons le kspace par 2

K_raw_for_sense=zeros(size(data_1,1),size(data_1,2),size(data_1,3));
samp_mat=zeros(size(data_1,1),size(data_1,2));


K_raw_test=data_1(:,1:acc_factor:end,:);


for p=1:acc_factor:size(data_1,2)
    
    K_raw_for_sense(:,p,:)=data_1(:,p,:);
    samp_mat(:,p)=1;
end

img_alias=ifft_2D(K_raw_for_sense);
img_alias_wrong=ifft_2D(K_raw_test);

% img_alias
ismrm_imshow(abs(img_alias),[0 max(abs(img_alias(:)))],[2 4]);
ismrm_imshow(abs(img_alias_wrong),[0 max(abs(img_alias_wrong(:)))],[2 4]);
% ismrm_imshow(abs(K_raw_for_sense),[0 max(abs(K_raw_for_sense(:)))],[2 4]);


figure(1)
subplot(1,2,1);
imagesc(abs(ifft_2D(K_raw_test(:,:,1))));
subplot(1,2,2);
imagesc(abs(img_alias(:,:,1)));

% extraire par ex la ligne 64 de la carte de sensibilitié  et l'afficher pour chaque antenne

x=64;

figure(1)
subplot(3,1,1);
for c=1:size(smaps,3)
    plot(squeeze(abs(smaps(x,:,c))));
    hold on;
end
subplot(3,1,2);
for c=1:size(smaps,3)
    plot(squeeze(abs(img_alias(x,:,c))));
    hold on;
end

dimx=size(smaps,1);
dimy=size(smaps,2);

n_blocks = size(smaps,2)/acc_factor;

image_unmix=zeros(size(smaps));

for x=1:256
    
    ligne=squeeze(smaps(x,:,:));
    ligne_img_alias=squeeze(img_alias(x,:,:));
    
    %choisir un pixel entre 1 et 127 et trouver le pixel aliasé correspondant
    
    ligne_image_unmix=zeros(size(ligne_img_alias));
    
    for i=1:n_blocks
                     
        %extraire la matrice de dimension [2, nombre d'antenne] correspondant à ces deux points]
        
        A=ligne([i:n_blocks:dimy], :).';
        
        %calculer les coefficients de dépliements à partir de la formule umix=
        %(S*ST)-1*ST
        
        unmix_1_pixel = pinv(A'* A) * A';
        
        %quelle est la dimension de umix
                     
        ligne_unmix([i:n_blocks:dimy],:)=unmix_1_pixel;
        
    end
    
    image_unmix(x,:,:)=ligne_unmix;
    
end


subplot(3,1,3);
for c=1:size(smaps,3)
    plot(squeeze(abs(image_unmix(:,c))));
    hold on;
end

figure()


for c=1:size(smaps,3)
    subplot(2,4,c);
    imagesc(abs(image_unmix(:,:,c)));
    hold on;
end

img_reco_sense_2 = sum(img_alias.*image_unmix,3);

figure(2)
imagesc(abs(img_reco_sense_2));
