% Load data
load('/media/jpleitao/Data/PhD/PDCTI/ATRSI/ATRSI-Assignments/TP1/data/ARX_Input1.mat');

time = ARX_Input1(1,:);
input = ARX_Input1(2,:);
output = ARX_Output1(2,:);

ts = time(2) - time(1);
input_frequency = 0.5;

% Plot the input and output data
plot(time, input, time, output)
legend('Input', 'Output')
xlabel('Time (s)')
ylabel('Value')

% FIXME: How to divide the dataset into estimation and validation data??

% Create iddata
z_input = iddata(ARX_Output1(2,:)', ARX_Input1(2,:)', ts);
z_input.Period = 1/input_frequency;
z_input.Tstart = 0;
get(z_input)

% Plot iddata
figure()
plot(z_input)

% Estimate inpulse response
figure()
Ge = spa(z_input);
bode(Ge)

% Estimate empirical step response
figure()
Mimp = impulseest(z_input);
step(Mimp);

% FIXME: Parei aqui!!


% Estimate model order (Even if i put na and nb = 1:100 it returns the
% same)
na = 1:10;
nb = 1:10;
nk = 1;
NN1 = struc(na, nb, nk);


z_input_e = iddata(ARX_Output1(2,1:350)', ARX_Input1(2,1:350)', ts);
z_input_v = iddata(ARX_Output1(2,350:end)', ARX_Input1(2,350:end)', ts);
% z_input_e(:,:,1) - Selects the first input (We just have one)
out = selstruc(arxstruc(z_input_e(:,:,1), z_input_v(:,:,1), NN1));