% *******************FUNCTION*************************
% FUNCTION:
% [tap_gain ,tap_delay,V] = LTEChannelModel(channel_type)
% DESCRIPTION:
% This function is to choose the paremeters of different channel
% INPUT:
% channel_type: the channel type, the choices of this paremeter are:...
% 'EPA','EVA','ETU'.
% OUTPUT:
% tap_gain= the gain of each channel tap
% tap_delay=time delay in ns
% V=the mobile speed in Km
% VERSION:  1.1  By Chenbing
% *****************************************************

function [tap_gain ,tap_delay,V] = LTEChannelModel(channel_type)
% ITU Channel Models
if channel_type=='EPA'   %Extended Pedestrian A model
   Pdb = [0 -1.0 -2.0 -3.0 -8.0 -17.2 -20.8];
   P=10.^(Pdb/10);
   tap_gain=sqrt(P/sum(P));
   tap_delay = [0 30 70 90 110 190 410]*1e-9;
   V=3;
elseif channel_type=='EVA' %Extended Vehicular A model
   Pdb = [0 -1.5 -1.4 -3.6 -0.6 -9.1 -7.0 -12.0 -16.9];
   P=10.^(Pdb/10);
   tap_gain=sqrt(P/sum(P));
   tap_delay = [0 30 150 310 370 710 1090 1730 2510]*1e-9;
   V=120;
elseif channel_type=='ETU'  %Extended Typical Urban model
   Pdb = [-1.0 -1.0 -1.0 0 0 0 -3.0 -5.0 -7.0];
   P=10.^(Pdb/10);
   tap_gain=sqrt(P/sum(P));
   tap_delay = [0 50 120 200 230 500 1600 2300 5000]*1e-9;
   V=3;

else
    error('Wrong input.');
end
