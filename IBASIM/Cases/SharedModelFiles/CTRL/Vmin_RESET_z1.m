function Vmin = Vmin_RESET_z1(Office,occupant,STD,Dense_Occupancy)
%% inputs
% office: office type (1-conference room mid 2,2-enclosed office mid 2, 3-open office mid 1, 4-enclosed office 5)
% occupant: in-office occupant number
% STD: 1-typical control, 2-high perfomance control
%% outputs
% Vmin: minimum ventilation rate [cfm]
%% main program
persistent N N_occ n VminOfficeTyp V_design V_0
if isempty(n)
    N=0;            % Count of timesteps between Vmin changes
    N_occ=0;        % Count of occupanyc timesteps
    n=4;            % Number of timesteps between supply air change [12min]
    VminOfficeTyp=[23 2 2 10;35 3 3 15]*20;   % Office minimum ventilation rate in typical control,20cfm/person [cfm]
    V_design=300;   % The design value of minimum ventilation rate in high-performance control [cfm]  
end

if STD==2   % high-performance control
    N=N+1;
    if occupant>0
        N_occ=N_occ+1;
    end
    if N>n              % for the reset-timestep 
        if N_occ==0     % occupants standby mode
            Vmin=0;
        else
            Vmin=V_design;
        end
        V_0=Vmin;       % record the current Vmin 
        N_occ=0;
        N=0;
    else                % for the non reset-timesetp
        if isempty(V_0)     % for the first few timesetp
            Vmin=V_design;
            V_0=Vmin;
        else                % for other timesetp
            Vmin=V_0;
        end
    end
    
elseif STD ==1   % typical control 
    Vmin=VminOfficeTyp((Dense_Occupancy+1),Office);
end

end
