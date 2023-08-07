%% Function to avoid SPM windows popping up all the time
%
% - when the file is named after the function (spm_my_defualts), will block
%   graphs and progress bars
% - change the name (e.g. to 'avoid_popups') to toggle off the effect 
% 
% Need to close / re-open matlab to make the change stick


function spm_my_defaults

  global defaults

  defaults.cmdline = true;

end