# file Bss3.xdc
# Digilent Basys3 pin mapping and constraints
# author Alexander Wirthmueller
# date created: 18 Oct 2018
# modified: 18 Oct 2018

# bank14 3.3V
set_property PACKAGE_PIN U18 [get_ports btnC];
set_property PACKAGE_PIN W19 [get_ports btnL];
set_property PACKAGE_PIN T17 [get_ports btnR];
set_property PACKAGE_PIN P17 [get_ports imclk];
set_property PACKAGE_PIN L17 [get_ports irxd];
set_property PACKAGE_PIN N17 [get_ports isck];
set_property PACKAGE_PIN P18 [get_ports iscl];
set_property PACKAGE_PIN R18 [get_ports isda];
set_property PACKAGE_PIN K17 [get_ports itxd];
set_property PACKAGE_PIN M18 [get_ports nirst];
set_property PACKAGE_PIN M19 [get_ports niss];
set_property PACKAGE_PIN V17 [get_ports {sw[0]}];
set_property PACKAGE_PIN V16 [get_ports {sw[1]}];
set_property PACKAGE_PIN W16 [get_ports {sw[2]}];
set_property PACKAGE_PIN W17 [get_ports {sw[3]}];
set_property PACKAGE_PIN W15 [get_ports {sw[4]}];
set_property PACKAGE_PIN V15 [get_ports {sw[5]}];
set_property PACKAGE_PIN W14 [get_ports {sw[6]}];
set_property PACKAGE_PIN W13 [get_ports {sw[7]}];

# bank16 3.3V
set_property PACKAGE_PIN B15 [get_ports amosi];
set_property PACKAGE_PIN A16 [get_ports asck];
set_property PACKAGE_PIN A15 [get_ports d15pwm];
set_property PACKAGE_PIN A17 [get_ports d60pwm];
set_property PACKAGE_PIN C15 [get_ports {lmio[0]}];
set_property PACKAGE_PIN A14 [get_ports nass];
set_property PACKAGE_PIN B16 [get_ports ppwm];
set_property PACKAGE_PIN C16 [get_ports {rmio[0]}];
set_property PACKAGE_PIN B18 [get_ports RsRx];
set_property PACKAGE_PIN A18 [get_ports RsTx];

# bank34 3.3V
set_property PACKAGE_PIN U2 [get_ports {an[0]}];
set_property PACKAGE_PIN U4 [get_ports {an[1]}];
set_property PACKAGE_PIN V4 [get_ports {an[2]}];
set_property PACKAGE_PIN W4 [get_ports {an[3]}];
set_property PACKAGE_PIN V7 [get_ports dp];
set_property PACKAGE_PIN W5 [get_ports extclk];
set_property PACKAGE_PIN W7 [get_ports {seg[0]}];
set_property PACKAGE_PIN W6 [get_ports {seg[1]}];
set_property PACKAGE_PIN U8 [get_ports {seg[2]}];
set_property PACKAGE_PIN V8 [get_ports {seg[3]}];
set_property PACKAGE_PIN U5 [get_ports {seg[4]}];
set_property PACKAGE_PIN V5 [get_ports {seg[5]}];
set_property PACKAGE_PIN U7 [get_ports {seg[6]}];
set_property PACKAGE_PIN T2 [get_ports {sw[10]}];
set_property PACKAGE_PIN R3 [get_ports {sw[11]}];
set_property PACKAGE_PIN W2 [get_ports {sw[12]}];
set_property PACKAGE_PIN U1 [get_ports {sw[13]}];
set_property PACKAGE_PIN T1 [get_ports {sw[14]}];
set_property PACKAGE_PIN R2 [get_ports {sw[15]}];
set_property PACKAGE_PIN V2 [get_ports {sw[8]}];
set_property PACKAGE_PIN T3 [get_ports {sw[9]}];

# bank35 3.3V
set_property PACKAGE_PIN K2 [get_ports nxss];
set_property PACKAGE_PIN H1 [get_ports sgrn];
set_property PACKAGE_PIN J1 [get_ports sred];
set_property PACKAGE_PIN L2 [get_ports tpwm];
set_property PACKAGE_PIN G2 [get_ports xmiso];
set_property PACKAGE_PIN H2 [get_ports xmosi];
set_property PACKAGE_PIN J2 [get_ports xsck];

# banks
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 14]];
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 16]];
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 35]];

# IP clks --- BEGIN
# clocks
create_clock -name extclk -period 10 -waveform {0 5} [get_ports extclk];
# IP clks --- END

