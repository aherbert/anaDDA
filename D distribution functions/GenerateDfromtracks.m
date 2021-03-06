function [D] = GenerateDfromtracks(tracks, input, truncation)
%Generates D from input data. Truncation is the maxium number of
%localisation used per track
%Structure of tracks (2D!) 
%   column 1: x position (unit???)
%   column 2: y position (unit???)
%   column 3: frame number
%   column 4: track id

%Structure of D 
%   column 1: avg. diff.coef.
%   column 2: tracklength (frames)
%   column 3: frame time (s)

nMolecules = size(tracks,1);
MSD = zeros(nMolecules,1);
kk = 1;
table = tabulate(tracks(:,4));

for i = 1:100   %JH: WHERE DOES THAT 100 COME FROM? Could bethe truncation values correct?
    selectedmolecules = table(table(:,2)==i+1);
    if ~isempty(selectedmolecules)
        kkstart = kk;
        sumindex = sum((table(1:selectedmolecules(1,1)-1,2)))+1;
        for ii = 1:numel(selectedmolecules)
            %%   Option1: Average D over all MSD of track (used all the time)
            if ii >1
                sumindex = sumindex+sum(table(selectedmolecules(ii-1):selectedmolecules(ii)-1,2));
            end
            index = sumindex;
            selectedtracks =tracks(index:index+i,1:3);
            maxlength = min([truncation+1 numel(selectedtracks(:,1))]);
            % sum all squared displacement in the track
            for jj = 1:maxlength-1
                if selectedtracks(jj+1,3)-selectedtracks(jj,3)==2
                    MSD(kk) = MSD(kk) + (((selectedtracks(jj+1,1) - selectedtracks(jj,1))^2 +...
                        (selectedtracks(jj+1,2) - selectedtracks(jj,2))^2)/2);
                else
                    MSD(kk) = MSD(kk) + (((selectedtracks(jj+1,1) - selectedtracks(jj,1))^2 +...
                        (selectedtracks(jj+1,2) - selectedtracks(jj,2))^2));
                end
            end
            MSD(kk) = MSD(kk)/(jj); % mean square displacement
            kk = kk + 1;
        end
        MSD(kkstart:kk-1,2) = maxlength-1;
    end
end

MSD(kk:end,:) = []; % delete unused rows
MSD(:,3) = input.frametime;
MSD = MSD';
MSD(1,:) = MSD(1,:).*input.pixelsize.^2/(4*input.frametime);
D = MSD;