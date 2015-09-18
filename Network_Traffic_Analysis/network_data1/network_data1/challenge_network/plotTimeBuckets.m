function plotTimeBuckets()
    close all;
    x = 1:15;
    x = x';
    y = ones(15,1);
    xy = [x;x;x;x;x; x;x;x;x;x; x;x;x;x;x];
    xy(:,2) = [y; y+1; y+2; y+3; y+4; y+5; y+6; y+7; y+8; y+9; y+10; y+11; y+12; y+13; y+14];
    xy = xy(1:220,:);
    xy2 = xy + rand(220,2);

    filename = 'AllNetworkData.csv';
    fid = fopen(filename);

    %% Iterate through every line in the file.
    numTCPpkts = 0;
	connections = [];

    startingTime = 225000;
    endingTime = 226000;
    stepSize = 1;
    bucketTime = startingTime + stepSize;
    idx = 1;
    figure();
    hold on;
    set(gcf,'DoubleBuffer','on');
    mov = avifile('network_vid', 'compression', 'Cinepak');
    mov.Fps = 5;

    while (1)
        %first get a new line, then test end condition (I need a real for loop)!
        str = fgetl(fid);
        %% end condition
        if (str == -1)
            break;
        end
        
        %% If this line is empty, then just go to the next line. 
        if (isempty(str))
            continue;
        end

        %% Header line
        % If this line begins with 'No.' then it is just a meaningless
        % header

        if (strcmp(str(1:5),'"No."'))
            continue;
        end

        x = textscan(str,'%d %n %s %s %s %[^\n]s', 'delimiter', '", ', 'MultipleDelimsAsOne', 1);
        % x is now formatted as follows:
        % x{1} = packet #
        % x{2} = timestamp
        % x{3} = source address
        % x{4} = destination address
        % x{5} = protocol
        % x{6} = info

        if (x{2} > endingTime)
            break;
        end
        if (x{2} < startingTime)
            continue;
        end

        %% TCP Packets
        % for now we're only concerned with TCP packets.
        if (strcmp(x{5},'TCP'))
            while (x{2} > bucketTime)
%                 subplot(3,3,idx);
                hold on;
                A = zeros(length(xy2));
                for ii=1:length(connections)
                   num = str2num(strrep(connections(ii).source{1},'.',' '));
                   row = num(4);
                   num = str2num(strrep(connections(ii).dest{1},'.',' '));
                   col = num(4);
                   A(row,col) = connections(ii).numPackets;
                end
                axis([0 16 0 16]);
                plotNodeGraph(A, xy2);
                [day, hour, minute, sec] = convertTime(bucketTime);
                text(11,15.1,['Day ' num2str(day) ' ' num2str(hour) ':' num2str(minute) ':' num2str(sec)]); 
                mov = addframe(mov,getframe(gcf));
%                 idx = idx + 1;
%                 if (idx > 9)
%                     idx = 1;
%                     figure();
%                 end
                bucketTime = bucketTime + stepSize;
                clf;
                connections = [];
            end
            connections = addEntry(connections, x{3}, x{4});
        end
    end    
    mov = close(mov);
end

function connections = addEntry(connections, source, dest)
    recordFound = false;
    if (~isempty(connections))
        for ii=1:length(connections)
            if (strcmp(connections(ii).source, source) && strcmp(connections(ii).dest, dest))
                connections(ii).numPackets = connections(ii).numPackets + 1;
                recordFound = true;     
            end
        end
    end
    if (recordFound == false)
        ii = length(connections) + 1;
        connections(ii).source = source;
        connections(ii).dest = dest;
        connections(ii).numPackets = 1;
    end
end

function [day, hour, minute, sec] = convertTime(totalSec)
    day = floor(totalSec/86400);
    rem = mod(totalSec,86400);
    hour = floor(rem/3600);
    rem = mod(rem,3600);
    minute = floor(rem/60);
    sec = mod(rem,60);
end