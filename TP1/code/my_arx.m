function [] = my_arx(path)

    % FIXME: Arranjar maneira de lhe passar os nomes ARX_Input1 e
    % ARX_Output1

    % Load data
    load(path);

    time = ARX_Input1(1, :);
    ts = time(2) - time(1);
    len = length(ARX_Input1(2,:));
    estimation_size = floor(0.7 * len);
    input_freq = 0.5;
    number_periods_e = floor(time(estimation_size) / (1/input_freq));
    number_periods_v = floor( (time(end) - time(estimation_size)) / ...
        (1/input_freq));

    % Estimate model order (Even if i put na and nb = 1:100 it returns the
    % same)
    na = 1:10;
    nb = 1:10;
    nk = 1;
    NN1 = struc(na, nb, nk);

    z_input_e = iddata(ARX_Output1(2, 1:estimation_size)', ARX_Input1(2, 1:estimation_size)', ts);
    z_input_e.Period = number_periods_e;
    z_input_e.Tstart = 0;

    z_input_v = iddata(ARX_Output1(2, estimation_size:end)', ARX_Input1(2, estimation_size:end)', ts);
    z_input_v.Period = number_periods_v;
    z_input_v.Tstart = 0;

    param_e = selstruc(arxstruc(z_input_e(:,:,1), z_input_v(:,:,1), NN1));
    
    estimator = recursiveARX(param_e);
    
    get(estimator)
end