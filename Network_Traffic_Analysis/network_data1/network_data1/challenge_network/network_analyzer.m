function [results, A] = network_analyzer(filename)
    fid = fopen(filename);
    tic
    %% Iterate through every line in the file.
    numTCPpkts = 0;
    results = [];
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

        %% TCP Packets
        % for now we're only concerned with TCP packets.
        if (strcmp(x{5},'TCP'))
            numTCPpkts = numTCPpkts + 1;
            results = addEntry(results, x{2}, x{3}, x{4});
        end
    end    
    toc

    A = [];
    for ii=1:length(results)
       num = str2num(strrep(results(ii).source{1},'.',' '));
       row = num(4);
       num = str2num(strrep(results(ii).dest{1},'.',' '));
       col = num(4);
       A(row,col) = results(ii).numPackets;
    end
end

function results = addEntry(results, timestamp, source, dest)
    recordFound = false;
    if (~isempty(results))
        for ii=1:length(results)
            if (strcmp(results(ii).source, source) && strcmp(results(ii).dest, dest))
                results(ii).numPackets = results(ii).numPackets + 1;
                recordFound = true;     
            end
        end
    end
    if (recordFound == false)
        ii = length(results) + 1;
        results(ii).timestamp = timestamp;
        results(ii).source = source;
        results(ii).dest = dest;
        results(ii).numPackets = 1;
    end
end