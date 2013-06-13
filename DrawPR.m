function DrawPR()
filehead='Hunt_Positive_Sweep'
information=load([filehead,'precision_recall.txt']);

x=information(:,4);
y=information(:,3);
txt_toMark=information(:,2);

plot(x,y,'--rs','LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',10)
title(['Precision-Recall of',filehead]);
xlabel('Recall');
ylabel('Precision');
text(x,y,num2str(txt_toMark));
end