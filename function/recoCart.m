function [im,im2,rawData]=recoCart(paramStructure)

    if nargin < 1
    [paramStructure]=readParams_Bruker();
    end
    
    if (paramStructure.ACQ_dim == 2)
        im2=zeros(paramStructure.PVM_EncMatrix(1),paramStructure.PVM_EncMatrix(2),paramStructure.NSLICES,paramStructure.NECHOES*paramStructure.PVM_NRepetitions,paramStructure.PVM_EncNReceivers);
    else
        im2=zeros(paramStructure.PVM_EncMatrix(1),paramStructure.PVM_EncMatrix(2),paramStructure.PVM_EncMatrix(3),paramStructure.NECHOES*paramStructure.PVM_NRepetitions,paramStructure.PVM_EncNReceivers);
    end
    
    rawData=readFIDMc(paramStructure.ACQ_size(1)/2,paramStructure.PVM_EncNReceivers,[paramStructure.dirPath '/fid']);
    
    for i=1:paramStructure.PVM_EncNReceivers
         if (paramStructure.ACQ_dim == 3)
            rawData{i}=double(reshape(rawData{i},paramStructure.PVM_EncMatrix(1),paramStructure.PVM_EncMatrix(2),paramStructure.PVM_EncMatrix(3),[]));
         else
            rawData{i}=double(reshape(rawData{i},paramStructure.PVM_EncMatrix(1),paramStructure.NSLICES,paramStructure.PVM_EncMatrix(2),[])); 
            rawData{i}=permute(rawData{i},[1 3 2 4]);
         end
         
        [a,b,c,d]=size(rawData{i});
        if d > 1

                if (paramStructure.ACQ_dim == 3)
                im2(:,:,:,:,i)=fftshift(fft(fft(fft(fftshift(rawData{i}),[],1),[],2),[],3));
                else
                    im2(:,:,:,:,i)=fftshift(fft(fft(fftshift(rawData{i}),[],1),[],2));
                end
 
        else
            if (paramStructure.ACQ_dim == 3)
        im2(:,:,:,i)=fftshift(fft(fft(fft(fftshift(rawData{i}),[],1),[],2),[],3));
            else
                im2(:,:,:,i)=fftshift(fft(fft(fftshift(rawData{i}),[],1),[],2));
            end
        end
    end
    

    if size(im2,3)==1
        im=sqrt(abs(im2).^2);
    else
        im=sqrt(sum(abs(im2).^2,length(size(im2))));
    end

    
end