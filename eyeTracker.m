function [el, edfFile] = eyeTracker(input, cfg, expParameters, varargin)

    if ~cfg.eyeTracker

        el = [];

    else

        switch input

            case 'Calibration'

                %% STEP 2
                % Provide Eyelink with details about the graphics environment
                %  and perform some initializations. The information is returned
                %  in a structure that also contains useful defaults
                %  and control codes (e.g. tracker state bit and Eyelink key values).
                el = EyelinkInitDefaults(cfg.win);

                % calibration has silver background with black targets, sound and smaller
                %  targets
                el.backgroundcolour        = [192 192 192, (cfg.win)];
                el.msgfontcolour           = BlackIndex(cfg.win);
                el.calibrationtargetcolour = BlackIndex(cfg.win);
                el.calibrationtargetsize   = 1;
                el.calibrationtargetwidth  = 0.5;
                el.displayCalResults       = 1;

                % call this function for changes to the calibration structure to take
                %  affect
                EyelinkUpdateDefaults(el);

                % STEP 3
                % Initialization of the connection with the Eyelink Gazetracker.
                %  exit program if this fails.

                % make sure EL is initialized.
                ELinit  = Eyelink('Initialize');
                if ELinit ~= 0
                    fprintf('Eyelink is not initialized, aborted.\n');
                    Eyelink('Shutdown');
                    Screen('CloseAll');
                    return
                end

                % make sure we're still connected.
                ELconnection = Eyelink('IsConnected');
                if ELconnection ~= 1
                    fprintf('Eyelink is not connected, aborted.\n');
                    Eyelink('Shutdown');
                    Screen('CloseAll');
                    return
                end

                %
                if ~EyelinkInit(0, 1)
                    fprintf('Eyelink Init aborted.\n');
                    return
                end

                % Open the edf file to write the data
                edfFile = 'demo.edf';
                Eyelink('Openfile', edfFile);

                [el.v, el.vs] = Eyelink('GetTrackerVersion');
                fprintf('Running experiment on a ''%s'' tracker.\n', el.vs);

                % make sure that we get gaze data from the Eyelink
                Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');

                % STEP 4
                % SET UP TRACKER CONFIGURATION
                % Setting the proper recording resolution, proper calibration type,
                %   as well as the data file content;
                %            Eyelink('command', 'add_file_preamble_text ''Recorded by 
                %EyelinkToolbox demo-experiment''');

                % This command is crucial to map the gaze positions from the tracker to
                %  screen pixel positions to determine fixation
                Eyelink('command', 'screen_pixel_coords = %ld %ld %ld %ld', 0, 0, 0, 0);
                Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, 0, 0);

                % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
                % DEFAULT CALIBRATION
                % set calibration type.
                Eyelink('command', 'calibration_type = HV5');

                % you must send this command with value NO for custom calibration
                %   you must also reset it to YES for subsequent experiments
                Eyelink('command', 'generate_default_targets = YES');
                % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

                %         % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
                %         % CUSTOM CALIBRATION
                %         % (SET MANUALLY THE DOTS COORDINATES, HERE FOR 6 DOTS)
                %         Eyelink('command', 'calibration_type = HV5');
                %         % you must send this command with value NO for custom calibration
                %         % you must also reset it to YES for subsequent experiments
                %         Eyelink('command', 'generate_default_targets = NO');
                %
                %         % calibration and validation target locations
                %         [width, height]=Screen('WindowSize', screenNumber);
                %         Eyelink('command','calibration_samples = 6');
                %         Eyelink('command','calibration_sequence = 0,1,2,3,4,5');
                %         Eyelink('command','calibration_targets = ...
                %             %d,%d %d,%d %d,%d %d,%d %d,%d',...
                %             640,512, ... %width/2,height/2
                %             640,102, ... %width/2,height*0.1
                %             640,614, ... %width/2,height*0.6
                %             128,341, ... %width*0.1,height*1/3
                %             1152,341 );  %width-width*0.1,height*1/3
                %
                %         Eyelink('command','validation_samples = 5');
                %         Eyelink('command','validation_sequence = 0,1,2,3,4,5');
                %         Eyelink('command','validation_targets = ...
                %             %d,%d %d,%d %d,%d %d,%d %d,%d',...
                %             640,512, ... %width/2,height/2
                %             640,102, ... %width/2,height*0.1
                %             640,614, ... %width/2,height*0.6
                %             128,341, ... %width*0.1,height*1/3
                %             1152,341 );  %width-width*0.1,height*1/3
                %         % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

                %             % set parser (conservative saccade thresholds)
                %             Eyelink('command', 'saccade_velocity_threshold = 35');
                %             Eyelink('command', 'saccade_acceleration_threshold = 9500');

                % set EDF file contents (not clear what this lines are used for)
                el.vsn = regexp(el.vs, '\d', 'match'); % wont work on EL

                % enter Eyetracker camera setup mode, calibration and validation
                EyelinkDoTrackerSetup(el);

                %             %         % do a final check of calibration using driftcorrection
                %             %         % You have to hit esc before return.
                %             %         EyelinkDoDriftCorrection(el);
                %
                %             %         % do a final check of calibration using driftcorrection
                %             %         success=EyelinkDoDriftCorrection(el);
                %             %         if success~=1
                %             %             Eyelink('shutdown');
                %             %             Screen('CloseAll');
                %             %             return;
                %             %         end

                % Go back to black screen
                Screen('FillRect', cfg.win, [0 0 0]);
                Screen('Flip', cfg.win);

            case 'StartRecording'

                % STEP 5
                % EyeLink Start recording the block
                Eyelink('Command', 'set_idle_mode');
                WaitSecs(0.05);
                Eyelink('StartRecording');
                %         % here to tag the recording, in the past caused delays during the
                %         %  presentation so I avoided to use it
                %         Eyelink('message',['TRIALID ',num2str(blocks),'_startTrial']);

                % check recording status, stop display if error
                checkrec = Eyelink('checkrecording');
                if checkrec ~= 0
                    fprintf('\nEyelink is not recording.\n\n');
                    Eyelink('Shutdown');
                    Screen('CloseAll');
                    return
                end

                % record a few samples before we actually start displaying
                %  otherwise you may lose a few msec of data
                WaitSecs(0.1);

                % HERE START THE STIMALTION OF THE BLOCK
                % to mark the beginning of the trial
                Eyelink('Message', 'SYNCTIME');

            case 'StopRecordings'

                % STEP 8
                % finish up: stop recording eye-movements,
                % EyeLink Stop recording the block
                Eyelink('Message', 'BLANK_SCREEN');
                % adds 100 msec of data to catch final events
                WaitSecs(0.1);
                % close graphics window, close data file and shut down tracker
                Eyelink('StopRecording');

            case 'Shutdown'

                edfFileName = expParameters.fileName.eyetracker;
                edfFile = 'demo.edf';

                % STEP 6
                % At the end of the experiment, save the edf file and shut down connection
                %  with Eyelink

                Eyelink('Command', 'set_idle_mode');
                WaitSecs(0.5);
                Eyelink('CloseFile');

                % download data file
                try
                    fprintf('Receiving data file ''%s''\n', edfFileName);
                    status = Eyelink('ReceiveFile', '', ...
                        [expParameters.outputDir, filesep, 'eyetracker', filesep, edfFileName]);
                    if status > 0
                        fprintf('ReceiveFile status %d\n', status);
                    end
                    if 2 == exist([expParameters.outputDir, filesep, 'eyetracker', ...
                            filesep, edfFileName], 'file')
                        fprintf('Data file ''%s'' can be found in ''%s''\n', edfFileName, ...
                            [expParameters.outputDir, filesep, 'eyetracker', filesep]);
                    end
                catch
                    fprintf('Problem receiving data file ''%s''\n', edfFileName);
                end

                Eyelink('shutdown');
                Screen('CloseAll');

        end

    end