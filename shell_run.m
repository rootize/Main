%1. For the continus run of Main.
% I'm going to buy something and make a call!
% Could be:  Airport_Positive
%            NSH_Povitive
%            Hunt_Positive_Sweep
filehead='Hunt_Positive_Sweep';
for threshold_set=0.85:0.01:0.95
   Main(filehead,1,threshold_set,0.5,4,1); 
end