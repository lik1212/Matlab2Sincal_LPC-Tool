function updateWaitbar(flag, hand, val, message)
% Updates the progress and message from a Waitbar or deletes a Waitbar.
% Also verifies if user aborted the process by clicking the cancel button.
%  
%
% Author: P.Gassler

switch flag
    case 'update'
        waitbar(val, hand, message)        
    case 'delete'
        delete(hand);
end