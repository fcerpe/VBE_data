function ds = structureTrial(opt, nbRun, modalityNb, directionNb )
  % sets up the target, chunk, labels by stimuli condition labels, runs,
  % number labels.

  % design info from opt
  %  nbRun = opt.mvpa.nbRun;
  betasPerCondition = opt.mvpa.nbTrialRepetition;

  chunks =  repmat(1 :(nbRun*betasPerCondition),1,6);
  chunks = chunks(:);
  
  modalityNb =  repmat(modalityNb,(nbRun*betasPerCondition),1);
  modalityNb = modalityNb(:);
  
  directionNb =  repmat(directionNb,(nbRun*betasPerCondition),1);
  directionNb = directionNb(:);
  
  % assign our 4D image design into cosmo ds git
  ds.sa.chunks = chunks;
  ds.sa.modality = modalityNb;
  ds.sa.targets = directionNb;

end