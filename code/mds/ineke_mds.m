%MDS per subject

RDM=zeros(20,20,1,19);
MDS=zeros(20,2,1,19);
stressSubject=zeros(1,1,19);
for subject = 1:19
dmean=matriceslda7T(:,:,1,subject);

mirrored=triu(dmean)+triu(dmean,1)';
RDM(:,:,1,subject)=mirrored;

RDMnow=RDM(:,:,1,subject);
%%%%%%%%%
scaling=min(min(RDMnow));
if scaling < 0
    scalingvalue=abs(scaling);
    RDMnow=RDMnow+scalingvalue;
    for i = 1:20
        RDMnow(i,i)=0;
    end
end
%%%%%%%%%
[MDS(:,:,1,subject),stress,disparities]=mdscale(RDMnow,2,'criterion','stress','replicates',5000);
stress
stressSubject(1,1,subject)=stress;

% MDS Plotting
plot(MDS(:,1,1,subject),MDS(:,2,1,subject),'k.','MarkerSize',10)
labels={'faces' 'bodies' 'hands' 'cats' 'fish' 'flowers' 'trees' 'veggies' 'chairs' 'hammers' 'scissors' 'instruments' 'cars' 'buildings' 'cubies' 'smoothies' 'fake script' 'words' 'numbers' 'scrambled'};
text(MDS(:,1,1,subject),MDS(:,2,1,subject),labels, 'VerticalAlignment','bottom','HorizontalAlignment','center');
title(['MDS of LDC, Left lateral hand region, ' 'normalized subject ' num2str(subject)],'FontSize',8,'FontName','arial','FontWeight','Bold')
if scaling < 0
    saveas(gcf,['MDS_LDCwodemean_Leftlat_NormalizedSubject' num2str(subject) '_UpscaledWith' num2str(scalingvalue) '.png']);%save matrix figure
else
    saveas(gcf,['MDS_LDCwodemean_Leftlat_NormalizedSubject' num2str(subject) '.png']);%save matrix figure
end
close(gcf)


clear dmean

save('LDCMDS_stress_pernormalizedsubject_LeftlatHandRegion.mat','stressSubject');
end


%make mds plot based on average matrix per ROI (note it if upscaling was needed)
RDM=zeros(20,20,1);
MDS=zeros(20,2,1);
stressMean=zeros(1,1);
dmean=meanOTC(:,:,1);

mirrored=triu(dmean)+triu(dmean,1)';
RDM(:,:,1)=mirrored;

RDMnow=RDM(:,:,1);
%%%%%%%%%
scaling=min(min(RDMnow));
if scaling < 0
    scalingvalue=abs(scaling);
    RDMnow=RDMnow+scalingvalue;
    for i = 1:20
        RDMnow(i,i)=0;
    end
end
%%%%%%%%%
[MDS(:,:,1),stress,disparities]=mdscale(RDMnow,2,'criterion','stress','replicates',5000);
stress
stressMean(1,1)=stress;
plot(MDS(:,1,1),MDS(:,2,1),'k.','MarkerSize',10)
labels={'faces' 'bodies' 'hands' 'cats' 'fish' 'flowers' 'trees' 'veggies' 'chairs' 'hammers' 'scissors' 'instruments' 'cars' 'buildings' 'cubies' 'smoothies' 'fake script' 'words' 'numbers' 'scrambled'};
text(MDS(:,1,1),MDS(:,2,1),labels, 'VerticalAlignment','bottom','HorizontalAlignment','center');
title(['MDS of LDC, Left lateral hand region, averaged across normalized subjects'],'FontSize',8,'FontName','arial','FontWeight','Bold')
if scaling < 0
    saveas(gcf,['MDS_LDCwodemean_LeftlatAveragedacrossnormalizedsubject_UpscaledWith' num2str(scalingvalue) '.png']);%save matrix figure
else
    saveas(gcf,['MDS_LDCwodemean_LeftlatAveragedacrossnormalizedsubject.png']);%save matrix figure
end
close(gcf)

clear dmean

save('LDCMDS_stress_averagedacrossnormalizedsubjects_leftlat.mat','stressMean');



%% Procrustes for every subject MDS results per ROI to the average MDS results

procsubjectMDScoord=zeros(20,2,4,19);
dsubject=zeros(1,4,19);
for subject = 1:19
    subjectMDScoord=MDS(:,:,1,subject);
    [dsubject(1,1,subject),procsubjectMDScoord(:,:,1,subject)]=procrustes(MDSavg(:,:,1),subjectMDScoord);
    clear subjectMDScoord

    subjectMDScoord=MDS(:,:,2,subject);
    [dsubject(1,2,subject),procsubjectMDScoord(:,:,2,subject)]=procrustes(MDSavg(:,:,2),subjectMDScoord);
    clear subjectMDScoord

    subjectMDScoord=MDS(:,:,3,subject);
    [dsubject(1,3,subject),procsubjectMDScoord(:,:,3,subject)]=procrustes(MDSavg(:,:,3),subjectMDScoord);
    clear subjectMDScoord

    subjectMDScoord=MDS(:,:,4,subject);
    [dsubject(1,4,subject),procsubjectMDScoord(:,:,4,subject)]=procrustes(MDSavg(:,:,4),subjectMDScoord);
end

%ROI Left lateral
%20 dots and 19 lines per dot, colored
colors=[
0.9019  0.4941  0.1333; % faces
0.8313  0.6745  0.0510; % bodies
0.7882  0.7529  0.0078; % hands
0.9020  0.1333  0.1333; % cats
0.8588  0.1529  0.6588; % fish
0.3412  0.0784  0.0118; % flowers
0.4196  0.3294  0.3059; % trees
0.4706  0.2627  0.0078; % veggies
0.4314  0.7137  0.3765; % object: chairs
0.2588  0.0118  0.6000; % hammers
0.4196  0.2824  0.6118; % scissors
0.7843  0.6784  0.9294; % instruments
0.5922  0.7882  0.5529; % cars
0.0784  0.4000  0.0157; % buildings
0.6902  0.6745  0.6745; % cubies
0.6824  0.6902  0.6745; % smoothies
0.2039  0.5961  0.8588; % fake script
0.0824  0.2627  0.3765; % words
0       0.9843  1;      % numbers
0.5020  0.5020  0.5020];  % scrambled

% Plot single subjects overlapping them
hold on;
for s = 1:size(procsubjectMDScoord,4)
    for i = 1:size(procsubjectMDScoord,1)
        dot_color = colors(i,:);
        plot(MDSavg(i,1,1),MDSavg(i,2,1),'Marker','.','MarkerSize',18,'Color',dot_color)
        labels={'faces' 'bodies' 'hands' 'cats' 'fish' 'flowers' 'trees' 'veggies' 'chairs' 'hammers' 'scissors' 'instruments' 'cars' 'buildings' 'cubies' 'smoothies' 'fake script' 'words' 'numbers' 'scrambled'};
        title(['MDS of LDC, left lateral hand region, averaged across normalized subjects'],'FontSize',8,'FontName','arial','FontWeight','Bold')
        line([MDSavg(i,1,1) procsubjectMDScoord(i,1,1,s)], [MDSavg(i,2,1) procsubjectMDScoord(i,2,1,s)], 'Color', dot_color, ...
            'LineStyle', ':', 'LineWidth', 0.75)
        text(MDSavg(i,1,1),MDSavg(i,2,1),labels{i},'FontSize',16,'FontName','arial','VerticalAlignment','bottom','HorizontalAlignment','center'); %'FontWeight','bold','Color', colors(i,:)
    end
end
set(gcf, 'Position', [1 1 1167 875]);
print(['MDS_Color_IndivSubjectLines_LDCwodemean_LeftLatAveragedacrossnormalizedsubject.png'], '-dpng', '-r300')
%saveas(gcf,['MDS_Color_IndivSubjectLines_LDCwodemean_LeftLatAveragedacrossnormalizedsubject.png']);
close(gcf)
