function program_nastran_determine(fname)

flagENDlog=0;

while flagENDlog==0
    
    pause(10); % allow nastran to generate *.log file
    
    tic
    if exist([fname '.log'],'file')==2
        
        flag=0;
        flag_time = 1;
        

        while flag==0 && flag_time
            
            fid100=fopen([fname '.log']);
            status=fseek(fid100,0,'eof');
            EOF=ftell(fid100);
            currentFPI=fseek(fid100,0,'bof');
            while currentFPI<EOF
                str=fgetl(fid100);
                currentFPI=ftell(fid100);
                if length(str)>45
                    if strcmp(str(1:20),'MSC Nastran finished')==1
                        flag=1;
                        %                         break
                    end
                    
                    elapsed_time=toc;
                    
                elseif elapsed_time>500 % sol145 takes around 6 mins.
                    
                    % no log file generated, stop this program
                    
                    
                    flag_time=0;
                    
                end
            end
            
            fclose(fid100);
        end
        
    end
    
    flagENDlog=1;
    
end
