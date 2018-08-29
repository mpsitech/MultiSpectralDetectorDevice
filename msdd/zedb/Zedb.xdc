# file Zedb.xdc
# ZedBoard pin mapping and constraints
# author Alexander Wirthmueller
# date created: 26 Aug 2018
# modified: 26 Aug 2018

# bank13 3.3V
set_property PACKAGE_PIN Y9 [get_ports extclk];
set_property PACKAGE_PIN Y11 [get_ports {JA[0]}];
set_property PACKAGE_PIN AA11 [get_ports {JA[1]}];
set_property PACKAGE_PIN Y10 [get_ports {JA[2]}];
set_property PACKAGE_PIN AA9 [get_ports {JA[3]}];
set_property PACKAGE_PIN AB11 [get_ports {JA[4]}];
set_property PACKAGE_PIN AB10 [get_ports {JA[5]}];
set_property PACKAGE_PIN AB9 [get_ports {JA[6]}];
set_property PACKAGE_PIN AA8 [get_ports {JA[7]}];
set_property PACKAGE_PIN U10 [get_ports oledDc];
set_property PACKAGE_PIN U9 [get_ports oledRes];
set_property PACKAGE_PIN AB12 [get_ports oledSclk];
set_property PACKAGE_PIN AA12 [get_ports oledSdin];
set_property PACKAGE_PIN U11 [get_ports oledVbat];
set_property PACKAGE_PIN U12 [get_ports oledVdd];

# bank34 1.8V
set_property PACKAGE_PIN J18 [get_ports amosi];
set_property PACKAGE_PIN M22 [get_ports asck];
set_property PACKAGE_PIN P16 [get_ports btnC];
set_property PACKAGE_PIN N15 [get_ports btnL];
set_property PACKAGE_PIN R18 [get_ports btnR];
set_property PACKAGE_PIN K19 [get_ports d15pwm];
set_property PACKAGE_PIN K20 [get_ports d60pwm];
set_property PACKAGE_PIN R21 [get_ports {gnd[2]}];
set_property PACKAGE_PIN P21 [get_ports imclk];
set_property PACKAGE_PIN T19 [get_ports irxd];
set_property PACKAGE_PIN P20 [get_ports isck];
set_property PACKAGE_PIN L17 [get_ports iscl];
set_property PACKAGE_PIN M17 [get_ports isda];
set_property PACKAGE_PIN R19 [get_ports itxd];
set_property PACKAGE_PIN J16 [get_ports {lmio[0]}];
set_property PACKAGE_PIN J17 [get_ports {lmio[1]}];
set_property PACKAGE_PIN M21 [get_ports nass];
set_property PACKAGE_PIN N17 [get_ports nirst];
set_property PACKAGE_PIN N18 [get_ports niss];
set_property PACKAGE_PIN T17 [get_ports nxss];
set_property PACKAGE_PIN K18 [get_ports ppwm];
set_property PACKAGE_PIN L21 [get_ports {rmio[0]}];
set_property PACKAGE_PIN L22 [get_ports {rmio[1]}];
set_property PACKAGE_PIN K21 [get_ports sgrn];
set_property PACKAGE_PIN J20 [get_ports sred];
set_property PACKAGE_PIN T16 [get_ports tpwm];
set_property PACKAGE_PIN R20 [get_ports xmiso];
set_property PACKAGE_PIN J22 [get_ports xmosi];
set_property PACKAGE_PIN J21 [get_ports xsck];

# bank35 1.8V
set_property PACKAGE_PIN B19 [get_ports {gnd[0]}];
set_property PACKAGE_PIN B20 [get_ports {gnd[1]}];
set_property PACKAGE_PIN F22 [get_ports {sw[0]}];
set_property PACKAGE_PIN G22 [get_ports {sw[1]}];
set_property PACKAGE_PIN H22 [get_ports {sw[2]}];
set_property PACKAGE_PIN F21 [get_ports {sw[3]}];
set_property PACKAGE_PIN H19 [get_ports {sw[4]}];
set_property PACKAGE_PIN H18 [get_ports {sw[5]}];
set_property PACKAGE_PIN H17 [get_ports {sw[6]}];
set_property PACKAGE_PIN M15 [get_ports {sw[7]}];

# banks
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]];

# IP clks --- BEGIN
# clocks
create_clock -name extclk -period 10 -waveform {0 5} [get_ports extclk];
# IP clks --- END

