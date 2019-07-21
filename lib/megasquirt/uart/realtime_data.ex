defmodule Megasquirt.UART.RealtimeData do
  import Megasquirt.UART.RealtimeData.Tools
  alias Megasquirt.MSL

  @msl_map %{
    "EGT7" => :egt7,
    "Knock cyl# 1" => :knock_cyl01,
    "Barometer" => :barometer,
    "VVT angle 4" => :vvt_ang4,
    "Sensor 12" => :sensor12,
    "EGT12" => :egt12,
    "VVT duty 4" => :vvt_duty4,
    "Knock cyl# 2" => :knock_cyl02,
    "Battery current" => :batt_curr,
    "PW" => :pw1,
    "porta" => :porta,
    # "MAF Freq" => :maf,
    "Launch retard timer" => :launch_timer,
    "Sensor 08" => :sensor08,
    "AFR3" => :afr3,
    # "Boost psi" =>
    "Sensor 01" => :sensor01,
    "SPK: External advance" => :ext_advance,
    "Gear" => :gear,
    "SDcard error" => :sd_error,
    "SPK: Flex Advance" => :flex_advance,
    "CEL status2" => :cel_status2,
    "SPK: Fuel cut retard " => :fc_retard,
    "TPSADC" => :tpsADC,
    "Launch timed retard" => :launch_retard,
    # "EAE2" =>
    # "Closed-loop idle RPM error" =>
    "AFR4" => :afr4,
    "MAT" => :mat,
    "Sensor 11" => :sensor11,
    "Status6" => :status6,
    # "Dome channel 1 empty duty" =>
    "MAP" => :map,
    "VSS4" => :vss4,
    "Seq PW8" => :pwseq8,
    "PWM D duty" => :duty_pwm_d,
    "Nitrous 1 duty" => :nitrous1_duty,
    # "MAPdot" =>
    # "Secondary load" =>
    "EGT1" => :egt1,
    "Fuel: Baro cor" => :baro_correction,
    "Sensor 06" => :sensor06,
    "VSS2dot" => :vss2dot,
    "GPS Altitude" => :gps_altm,
    "Accel Y" => :accely,
    "PWM C duty" => :duty_pwm_c,
    "Sensor 07" => :sensor07,
    "Sensor 15" => :sensor15,
    "Ign load" => :ignload,
    "Boost duty 2" => :boostduty2,
    "VSS1" => :vss1,
    # "Shaft rpm 1" =>
    "MAF volts" => :maf_volts,
    "SPK: Base Spark Advance" => :base_advance,
    "ALS added fuel" => :als_addfuel,
    "VSS4 ms-1" => :vss4_ms_1,
    "Status5" => :status5,
    "Fuel temperature cor" => :fueltemp_cor,
    "PWM A duty" => :duty_pwm_a,
    "VSS2" => :vss2,
    # "Duty Cycle1" =>
    "SDcard status" => :sd_status,
    "portb" => :portb,
    "TPS accel" => :tps_accel,
    "MAF" => :maf,
    "AFR" => :afr1,
    "VVT target 1" => :vvt_target1,
    "canout1_8" => :canout1_8,
    "portmj" =>  :portmj,
    # "Engine idling" =>
    "canout9_16" => :canout9_16,
    "Alternator target voltage" => :alt_targv,
    "MAFload" => :mafload,
    "Knock cyl# 5" => :knock_cyl05,
    "Status1" => :status1,
    "EGO cor7" => :egocor7,
    "VVT duty 3" => :vvt_duty3,
    "SPK: Cold advance" => :coldAdvDeg,
    "RPMdot" => :rpm_dot,
    "Fuel Pressure2_psi" => :fuel_press2,
    "Seq PW5" => :pwseq5,
    "VE1 raw" => :ve_raw1,
    "SPK: 3-step Timing" => :step3_timing,
    "Timing err" => :timing_err,
    "GPS Speed ms-1" => :gps_speed_ms_1,
    "Status9" => :status9,
    "VE2 raw" => :ve_raw2,
    "Engine" => :engine,
    "SPK: MAT Retard" => :mat_retard,
    "PWM B duty" => :generic_pid_duty_b,
    # "GPS Accuracy" =>
    "PW2" => :pw2,
    "EGT4" => :egt4,
    "Injector timing sec" => :inj_timing_sec,
    # "AFR 1 Error" =>
    "Nitrous Timer" => :nitrous_timer,
    "Fuel pump control duty" => :fp_duty,
    "Fuel Pressure1_bar" => :fuel_press1,
    "RPM" => :rpm,
    "Seq PW1" => :pwseq1,
    "Seq PW7" => :pwseq7,
    "SPK: Spark Advance" => :advance,
    "Knock cyl# 8" => :knock_cyl08,
    "SPK: CEL retard" => :cel_retard,
    "Knock cyl# 3" => :knock_cyl03,
    "GPS Speed" => :gps_speed,
    "Fuel: Accel enrich" => :total_accel,
    "VVT target 4" => :vvt_target4,
    # "CANpwmin3" =>
    "AFR5" => :afr5,
    "TPS" => :tps,
    "AFR7" => :afr7,
    "Boost target 2" => :boost_targ_2,
    "GPS Course (deg)" => :gps_course,
    "Water inj duty" => :water_duty,
    "Load" => :load,
    "MAP accel" => :map_accel,
    # "CANpwmin0" =>
    # "SPK: Idle Correction Advance" =>
    # "SPK: Launch VSS Retard" =>
    # "Total accel" =>
    # "portk" =>
    # "porteh" =>
    # "SPK: Spark Table 3" =>
    # "EGO cor2" =>
    # "XAcc" =>
    # "Wall fuel1" =>
    # "Status4" =>
    # "Sensor 13" =>
    # "GPS State" =>
    # "VVT angle 1" =>
    # "TC slip * time" =>
    # "VSS1dot" =>
    # "CANpwmin2" =>
    # "EGO cor3" =>
    # "SPK: Traction retard " =>
    # "Seq PW3" =>
    "SecL" => :secs,
    # "Closed-loop idle target RPM" =>
    # "EGT3" =>
    # "Knock cyl# 4" =>
    # "SPK: ALS Timing" =>
    # "VVT target 2" =>
    # "EAE load" =>
    # "Fuel: Air cor" =>
    # "Seq PW6" =>
    # "VSS1 ms-1" =>
    # "Engine WOT" =>
    # "Stepper Idle position" =>
    # "Lost sync reason" =>
    # "Fuel flow cc/min" =>
    # "VVT target 3" =>
    # "SPK: Spark Table 4" =>
    # "Sensor 09" =>
    # "Knock cyl# 7" =>
    # "Status7" =>
    # "Fuel Pressure1_psi" =>
    # "EGO cor6" =>
    # "canin1_8" =>
    # "EGT8" =>
    # "VE1" =>
    # "AFR 2 Target" =>
    # "Lost sync count" =>
    # "Alternator control duty" =>
    # "Dome target 1" =>
    # "Knock in" =>
    # "Fuel: Accel PW" =>
    # "EGT11" =>
    # "Engine in cruise state" =>
    # "Dome channel 1 fill duty" =>
    # "GPS Num Sats" =>
    # "Mainloop time" =>
    # "VE2" =>
    # "Engine in overrun" =>
    # "SPK: Knock retard" =>
    # "Sensor 14" =>
    # "Status8" =>
    # "Latitude" =>
    # "SPK: Nitrous Retard" =>
    # "Status2" =>
    # "Secondary ign load" =>
    # "VVT angle 2" =>
    # "Alternator control period" =>
    # "Fuel Pressure2_bar" =>
    # "Accel Z" =>
    # "EAE1" =>
    # "PWM Idle duty" =>
    # "Sensor 02" =>
    "CLT" => :coolant,
    # "MPG(UK)" =>
    # "CAN error bits" =>
    # "Sensor 04" =>
    # "l/100km" =>
    # "SDcard file number" =>
    # "AFR2" =>
    # "VVT angle 3" =>
    # "VE3 raw" =>
    # "AFR6" =>
    # "Engine accelerating slowly" =>
    # "portt" =>
    # "PWM F duty" =>
    # "EGT6" =>
    # "Fuel: Total cor" =>
    # "VSS3 ms-1" =>
    # "Loop" =>
    # "Fuel Temp2" =>
    # "AFR load" =>
    # "SPK: Revlim Retard" =>
    # "CAN error count" =>
    # "Fuel Pressure1_kPa" =>
    # "MPG(USA)" =>
    # "Ethanol Percentage" =>
    # "Accel X" =>
    # "Status5s" =>
    # "Nitrous 2 duty" =>
    # "EGO cor5" =>
    # "Time" =>
    # "Sensor 03" =>
    # "AFR 1 Target" =>
    # "PWM E duty" =>
    # "Generic Closed-Loop B duty" =>
    # "Wall fuel2" =>
    # "Injector timing pri" =>
    # "CEL status" =>
    # "Dwell" =>
    # "Seq PW4" =>
    # "Accelerator Pedal/Grip Position" =>
    # "Fuel pressure cor" =>
    # "Alternator load" =>
    # "Throttle Target" =>
    # "GPS Latitude" =>
    # "CANpwmin1" =>
    # "AFR 2 Error" =>
    # "AFR8" =>
    # "EGO cor4" =>
    # "VVT duty 1" =>
    # "Sensor 16" =>
    # "Batt V" =>
    # "SPK: Spark Table 2" =>
    # "Longitude" =>
    # "EGO cor1" =>
    # "GPS Longitude" =>
    # "SPK: Launch Timing" =>
    # "Fuel Temp1" =>
    # "Status3" =>
    # "Boost duty" =>
    # "Fuel: Warmup cor" =>
    # "VSS2 ms-1" =>
    # "SDcard phase" =>
    # "Knock cyl# 6" =>
    # "VVT duty 2" =>
    # "EGT10" =>
    # "EGT5" =>
    # "SPK: Spark Table 1" =>
    # "EGT2" =>
    # "Seq PW2" =>
    # "Sensor 05" =>
    # "TPSdot" =>
    # "VSS3" =>
    # "ZAcc" =>
    # "Fuel Pressure2_kPa" =>
    # "VE4 raw" =>
    # "Long term fuel trim cor" =>
    # "portp" =>
    # "Duty Cycle2" =>
    # "Shaft rpm 2" =>
    # "Engine decelerating slowly" =>
    # "E85 Fuel Correction" =>
    # "EGT9" =>
    # "Sensor 10" =>
    # "Nitrous added fuel" =>
    # "CEL error code" =>
    # "YAcc" =>
    # "EGO cor8" =>
    # "Boost target 1" =>
    # "Generic Closed-Loop A duty" =>
  }

  def from_msl(%MSL{data: data}) do
    Enum.map(data, &from_msl/1)
  end

  def from_msl(%{} = record) do
    Map.new(record, fn
      {msl_key, value} -> {@msl_map[msl_key], value}
    end)
  end

  @doc """
  Return a map based on realtime data described in the
  `ms3.ini` file
  """
  # defining a `bit` output_channel here will
  # require defining a function of the same name that
  # will take a binary as described in the output_channel
  output_channels <<
    output_channel(secs, false, 16, "s", 1.000, 0.0),
    output_channel(pw1, false, 16, "ms", 0.001, 0.0),
    output_channel(pw2, false, 16, "ms", 0.001, 0.0),
    output_channel(rpm, false, 16, "RPM", 1.00, 0.0),
    output_channel(advance, true, 16, "deg", 0.100, 0.0),
    output_channel(squirt, false, 8, "bit", 1.000, 0.0),
    output_channel(engine, false, 8, "bit", 1.00, 0.0),
    output_channel(afttgt1raw, false, 8, "AFR", 0.1, 0.0),
    output_channel(afttgt2raw, false, 8, "AFR", 0.1, 0.0),
    output_channel(wbo2_en1, false, 8, "", 0.1, 0.0),
    output_channel(wbo2_en2, false, 8, "", 0.1, 0.0),
    output_channel(barometer, true, 16, "kPa", 0.100, 0.0),
    output_channel(map, true, 16, "kPa", 0.100, 0.0),
    output_channel(mat, true, 16, "�F", 0.100, 0.0),
    output_channel(coolant, true, 16, "�F", 0.100, 0.0),
    output_channel(tps, true, 16, "%", 0.100, 0.0),
    output_channel(battery_voltage, true, 16, "v", 0.100, 0.0),
    output_channel(afr1_old, true, 16, "AFR", 0.100, 0.0),
    output_channel(afr2_old, true, 16, "AFR", 0.100, 0.0),
    output_channel(knock, true, 16, "%", 0.100, 0.0),
    output_channel(ego_correction_1, true, 16, "%", 0.1000, 0.0),
    output_channel(ego_correction_2, true, 16, "%", 0.1000, 0.0),
    output_channel(air_correction, true, 16, "%", 0.1000, 0.0),
    output_channel(warmup_enrich, true, 16, "%", 1.000, 0.0),
    output_channel(accel_enrich, true, 16, "ms", 0.100, 0.0),
    output_channel(tps_fuel_cut, true, 16, "%", 1.000, 0.0),
    output_channel(baro_correction, true, 16, "%", 0.1000, 0.0),
    output_channel(gamma_enrich, true, 16, "%", 1.000, 0.0),
    output_channel(veCurr1, true, 16, "%", 0.1000, 0.0),
    output_channel(veCurr2, true, 16, "%", 0.1000, 0.0),
    output_channel(iacstep, true, 16, "", 1.000, 0.0),
    output_channel(idleDC, true, 16, "%", 0.392, 0.0),
    output_channel(coldAdvDeg, true, 16, "deg", 0.100, 0.0),
    output_channel(tps_dot, true, 16, "%/s", 0.100, 0.0),
    output_channel(map_dot, true, 16, "kPa/s", 1.000, 0.0),
    output_channel(dwell, false, 16, "ms", 0.1000, 0.0),
    output_channel(mafload, true, 16, "kPa", 0.1000, 0.0),
    output_channel(fuelload, true, 16, "fuelload", 0.100, 0.0),
    output_channel(fuelCorrection, true, 16, "%", 1.000, 0.0),
    output_channel(sd_status, false, 8, "", 1.0, 0.0),
    output_channel(knockRetard, false, 8, "deg", 0.1, 0.0),
    output_channel(eae_fuel_corr_1, false, 16, "%", 1.0, 0.0),
    output_channel(egoV, true, 16, "V", 0.01, 0.0),
    output_channel(egoV2, true, 16, "V", 0.01, 0.0),
    output_channel(status1, false, 8, "", 1.0, 0.0),
    output_channel(status2, false, 8, "", 1.0, 0.0),
    output_channel(status3, false, 8, "", 1.0, 0.0),
    output_channel(status4, false, 8, "", 1.0, 0.0),
    output_channel(status6, false, 8, "", 1.0, 0.0),
    output_channel(status7, false, 8, "", 1.0, 0.0),
    output_channel(status5, false, 16, "", 1, 0),
    output_channel(status5s, true, 16, "", 1, 0),
    output_channel(cel_status, false, 16, "bit", 1.000, 0.0),
    output_channel(fuelload2, true, 16, "fuelload", 0.100, 0.0),
    output_channel(ignload, true, 16, "%", 0.100, 0.0),
    output_channel(ignload2, true, 16, "%", 0.100, 0.0),
    output_channel(synccnt, false, 8, "", 1, 0),
    output_channel(syncreason, false, 8, "", 1.0, 0.0),
    output_channel(wallfuel1, false, 32, "uS", 0.010, 0.0),
    output_channel(wallfuel2, false, 32, "uS", 1.000, 0.0),
    output_channel(sensor01, true, 16, "", 0.1000, 0.0),
    output_channel(sensor02, true, 16, "", 0.1000, 0.0),
    output_channel(sensor03, true, 16, "", 0.1000, 0.0),
    output_channel(sensor04, true, 16, "", 0.1000, 0.0),
    output_channel(sensor05, true, 16, "", 0.1000, 0.0),
    output_channel(sensor06, true, 16, "", 0.1000, 0.0),
    output_channel(sensor07, true, 16, "", 0.1000, 0.0),
    output_channel(sensor08, true, 16, "", 0.1000, 0.0),
    output_channel(sensor09, true, 16, "", 0.1000, 0.0),
    output_channel(sensor10, true, 16, "", 0.1000, 0.0),
    output_channel(sensor11, true, 16, "", 0.1000, 0.0),
    output_channel(sensor12, true, 16, "", 0.1000, 0.0),
    output_channel(sensor13, true, 16, "", 0.1000, 0.0),
    output_channel(sensor14, true, 16, "", 0.1000, 0.0),
    output_channel(sensor15, true, 16, "", 0.1000, 0.0),
    output_channel(sensor16, true, 16, "", 0.1000, 0.0),
    output_channel(canin1_8, false, 8, "", 1.000, 0.0),
    output_channel(canout1_8, false, 8, "", 1.000, 0.0),
    output_channel(canout9_16, false, 8, "", 1.000, 0.0),
    output_channel(boostduty, false, 8, "%", 1.0, 0.0),
    output_channel(n2o_addfuel, true, 16, "ms", 0.001, 0),
    output_channel(n2o_retard, true, 16, "deg", 0.1, 0),
    output_channel(pwseq1, false, 16, "ms", 0.001, 0.0),
    output_channel(pwseq2, false, 16, "ms", 0.001, 0.0),
    output_channel(pwseq3, false, 16, "ms", 0.001, 0.0),
    output_channel(pwseq4, false, 16, "ms", 0.001, 0.0),
    output_channel(pwseq5, false, 16, "ms", 0.001, 0.0),
    output_channel(pwseq6, false, 16, "ms", 0.001, 0.0),
    output_channel(pwseq7, false, 16, "ms", 0.001, 0.0),
    output_channel(pwseq8, false, 16, "ms", 0.001, 0.0),
    output_channel(pwseq9, false, 16, "ms", 0.001, 0.0),
    output_channel(pwseq10, false, 16, "ms", 0.001, 0.0),
    output_channel(pwseq11, false, 16, "ms", 0.001, 0.0),
    output_channel(pwseq12, false, 16, "ms", 0.001, 0.0),
    output_channel(pwseq13, false, 16, "ms", 0.001, 0.0),
    output_channel(pwseq14, false, 16, "ms", 0.001, 0.0),
    output_channel(pwseq15, false, 16, "ms", 0.001, 0.0),
    output_channel(pwseq16, false, 16, "ms", 0.001, 0.0),
    output_channel(nitrous1_duty, false, 8, "%", 1, 0),
    output_channel(nitrous2_duty, false, 8, "%", 1, 0),
    output_channel(egt1, true, 16, "�F", 0.1, 0),
    output_channel(egt2, true, 16, "�F", 0.1, 0),
    output_channel(egt3, true, 16, "�F", 0.1, 0),
    output_channel(egt4, true, 16, "�F", 0.1, 0),
    output_channel(egt5, true, 16, "�F", 0.1, 0),
    output_channel(egt6, true, 16, "�F", 0.1, 0),
    output_channel(egt7, true, 16, "�F", 0.1, 0),
    output_channel(egt8, true, 16, "�F", 0.1, 0),
    output_channel(egt9, true, 16, "�F", 0.1, 0),
    output_channel(egt10, true, 16, "�F", 0.1, 0),
    output_channel(egt11, true, 16, "�F", 0.1, 0),
    output_channel(egt12, true, 16, "�F", 0.1, 0),
    output_channel(dome_fill_duty1, false, 8, "%", 1, 0),
    output_channel(dome_fill_duty2, false, 8, "%", 1, 0),
    output_channel(dome_empty_duty1, false, 8, "%", 1, 0),
    output_channel(dome_empty_duty2, false, 8, "%", 1, 0),
    output_channel(app, true, 16, "%", 0.0100, 0.0),
    output_channel(throttle_targ, true, 16, "%", 0.0100, 0.0),
    output_channel(maf, false, 16, "g/sec", 1.000, 0.0),
    output_channel(canpwmin0, false, 16, "", 1.000, 0.0),
    output_channel(canpwmin1, false, 16, "", 1.000, 0.0),
    output_channel(canpwmin2, false, 16, "", 1.000, 0.0),
    output_channel(canpwmin3, false, 16, "", 1.000, 0.0),
    output_channel(fuelflow, false, 16, "cc/min", 1, 0.0),
    output_channel(fuelcons, false, 16, "l/km", 1, 0.0),
    output_channel(eae_fuel_corr_2, false, 16, "%", 1.0, 0.0),
    output_channel(tpsADC, false, 16, "ADC", 1, 0),
    output_channel(eaeload1, true, 16, "eaeload1", 0.1000, 0.0),
    output_channel(afrload1, true, 16, "afrload1", 0.1000, 0.0),
    output_channel(gear, false, 8, "", 1, 0),
    output_channel(timing_err, true, 08, "%", 1, 0),
    output_channel(rpm_dot, true, 16, "rpm/sec", 10, 0),
    output_channel(vss1dot, true, 16, "ms-2", 0.1, 0),
    output_channel(vss2dot, true, 16, "ms-2", 0.1, 0),
    output_channel(accelx, true, 16, "ms-2", 0.001, 0),
    output_channel(accely, true, 16, "ms-2", 0.001, 0),
    output_channel(accelz, true, 16, "ms-2", 0.001, 0),
    output_channel(duty_pwm_a, false, 8, "%", 1, 0),
    output_channel(duty_pwm_b, false, 8, "%", 1, 0),
    output_channel(duty_pwm_c, false, 8, "%", 1, 0),
    output_channel(duty_pwm_d, false, 8, "%", 1, 0),
    output_channel(duty_pwm_e, false, 8, "%", 1, 0),
    output_channel(duty_pwm_f, false, 8, "%", 1, 0),
    output_channel(afr1, false, 8, "AFR", 0.1, 0.0),
    # output_channel(afr2, false, 8, "AFR", 0.1, 0.0),
    # output_channel(afr3, false, 8, "AFR", 0.1, 0.0),
    # output_channel(afr4, false, 8, "AFR", 0.1, 0.0),
    # output_channel(afr5, false, 8, "AFR", 0.1, 0.0),
    # output_channel(afr6, false, 8, "AFR", 0.1, 0.0),
    # output_channel(afr7, false, 8, "AFR", 0.1, 0.0),
    # output_channel(afr8, false, 8, "AFR", 0.1, 0.0),
    # output_channel(afr9, false, 8, "AFR", 0.1, 0.0),
    # output_channel(afr10, false, 8, "AFR", 0.1, 0.0),
    # output_channel(afr11, false, 8, "AFR", 0.1, 0.0),
    # output_channel(afr12, false, 8, "AFR", 0.1, 0.0),
    # output_channel(afr13, false, 8, "AFR", 0.1, 0.0),
    # output_channel(afr14, false, 8, "AFR", 0.1, 0.0),
    # output_channel(afr15, false, 8, "AFR", 0.1, 0.0),
    # output_channel(afr16, false, 8, "AFR", 0.1, 0.0),
    # output_channel(egov1, false, 16, "V", 0.00489, 0.0),
    # output_channel(egov2, false, 16, "V", 0.00489, 0.0),
    # output_channel(egov3, false, 16, "V", 0.00489, 0.0),
    # output_channel(egov4, false, 16, "V", 0.00489, 0.0),
    # output_channel(egov5, false, 16, "V", 0.00489, 0.0),
    # output_channel(egov6, false, 16, "V", 0.00489, 0.0),
    # output_channel(egov7, false, 16, "V", 0.00489, 0.0),
    # output_channel(egov8, false, 16, "V", 0.00489, 0.0),
    # output_channel(egov9, false, 16, "V", 0.00489, 0.0),
    # output_channel(egov10, false, 16, "V", 0.00489, 0.0),
    # output_channel(egov11, false, 16, "V", 0.00489, 0.0),
    # output_channel(egov12, false, 16, "V", 0.00489, 0.0),
    # output_channel(ve_raw1, true, 16, "%", 0.1000, 0.0),
    # output_channel(ve_raw2, true, 16, "%", 0.1000, 0.0),
    # output_channel(ve_raw3, true, 16, "%", 0.1000, 0.0),
    # output_channel(ve_raw4, true, 16, "%", 0.1000, 0.0),
    # output_channel(egocor1, true, 16, "%", 0.1000, 0.0),
    # output_channel(egocor2, true, 16, "%", 0.1000, 0.0),
    # output_channel(egocor3, true, 16, "%", 0.1000, 0.0),
    # output_channel(egocor4, true, 16, "%", 0.1000, 0.0),
    # output_channel(egocor5, true, 16, "%", 0.1000, 0.0),
    # output_channel(egocor6, true, 16, "%", 0.1000, 0.0),
    # output_channel(egocor7, true, 16, "%", 0.1000, 0.0),
    # output_channel(egocor8, true, 16, "%", 0.1000, 0.0),
    # output_channel(egocor9, true, 16, "%", 0.1000, 0.0),
    # output_channel(egocor10, true, 16, "%", 0.1000, 0.0),
    # output_channel(egocor11, true, 16, "%", 0.1000, 0.0),
    # output_channel(egocor12, true, 16, "%", 0.1000, 0.0),
    # output_channel(ports, false, 8, "bit", 1.000, 0.0),
    # output_channel(portm, false, 8, "bit", 1.000, 0.0),
    # output_channel(boost_dome_targ1, true, 16, "kPa", 0.1, 0),
    # output_channel(boost_dome_targ2, true, 16, "kPa", 0.1, 0),
    # output_channel(status9, false, 8, "", 1, 0),
    # output_channel(stream_level, false, 8, "", 1, 0),
    # output_channel(water_duty, false, 8, "%", 1, 0),
    # output_channel(dwell_trl, false, 16, "ms", 0.1000, 0.0),
    # output_channel(vss1, false, 16, "vss", 1.000, 0.0),
    # output_channel(vss2, false, 16, "vss", 1.000, 0.0),
    # output_channel(vss1_ms_1, false, 16, "ms-1", 0.1, 0.0),
    # output_channel(vss2_ms_1, false, 16, "ms-1", 0.1, 0.0),
    # output_channel(ss1, false, 16, "RPM", 10.000, 0.0),
    # output_channel(ss2, false, 16, "RPM", 10.000, 0.0),
    # output_channel(nitrous_timer, false, 16, "s", 0.001, 0),
    # output_channel(sd_filenum, false, 16, "", 1, 0),
    # output_channel(sd_error, false, 8, "", 1, 0),
    # output_channel(sd_phase, false, 8, "", 1, 0),
    # output_channel(boostduty2, false, 8, "%", 1.0, 0.0),
    # output_channel(status8, false, 8, "", 1.0, 0.0),
    # output_channel(vvt_ang1, true, 16, "deg", 0.100, 0.0),
    # output_channel(vvt_ang2, true, 16, "deg", 0.100, 0.0),
    # output_channel(vvt_ang3, true, 16, "deg", 0.100, 0.0),
    # output_channel(vvt_ang4, true, 16, "deg", 0.100, 0.0),
    # output_channel(inj_timing_pri, true, 16, "deg", 0.100, 0.0),
    # output_channel(inj_timing_sec, true, 16, "deg", 0.100, 0.0),
    # output_channel(vvt_target1, true, 16, "deg", 0.100, 0.0),
    # output_channel(vvt_target2, true, 16, "deg", 0.100, 0.0),
    # output_channel(vvt_target3, true, 16, "deg", 0.100, 0.0),
    # output_channel(vvt_target4, true, 16, "deg", 0.100, 0.0),
    # output_channel(vvt_duty1, false, 8, "%", 0.392, 0.0),
    # output_channel(vvt_duty2, false, 8, "%", 0.392, 0.0),
    # output_channel(vvt_duty3, false, 8, "%", 0.392, 0.0),
    # output_channel(vvt_duty4, false, 8, "%", 0.392, 0.0),
    # output_channel(fuel_pct, false, 16, "%", 0.1000, 0.0),
    # output_channel(fuel_temp1, true, 16, "�F", 0.100, 0.0),
    # output_channel(fuel_temp2, true, 16, "�C", 0.05555, -320.0),
    # output_channel(tps_accel, true, 16, "%", 0.1000, 0.0),
    # output_channel(map_accel, true, 16, "%", 0.1000, 0.0),
    # output_channel(total_accel, true, 16, "%", 0.1000, 0.0),
    # output_channel(knock_cyl01, false, 8, "%", 0.4, 0),
    # output_channel(knock_cyl02, false, 8, "%", 0.4, 0),
    # output_channel(knock_cyl03, false, 8, "%", 0.4, 0),
    # output_channel(knock_cyl04, false, 8, "%", 0.4, 0),
    # output_channel(knock_cyl05, false, 8, "%", 0.4, 0),
    # output_channel(knock_cyl06, false, 8, "%", 0.4, 0),
    # output_channel(knock_cyl07, false, 8, "%", 0.4, 0),
    # output_channel(knock_cyl08, false, 8, "%", 0.4, 0),
    # output_channel(knock_cyl09, false, 8, "%", 0.4, 0),
    # output_channel(knock_cyl10, false, 8, "%", 0.4, 0),
    # output_channel(knock_cyl11, false, 8, "%", 0.4, 0),
    # output_channel(knock_cyl12, false, 8, "%", 0.4, 0),
    # output_channel(knock_cyl13, false, 8, "%", 0.4, 0),
    # output_channel(knock_cyl14, false, 8, "%", 0.4, 0),
    # output_channel(knock_cyl15, false, 8, "%", 0.4, 0),
    # output_channel(knock_cyl16, false, 8, "%", 0.4, 0),
    # output_channel(launch_timer, false, 16, "s", 0.001, 0),
    # output_channel(launch_retard, true, 16, "deg", 0.1, 0),
    # output_channel(maf_volts, false, 16, "V", 0.001, 0.0),
    # output_channel(porta, false, 8, "bit", 1.000, 0.0),
    # output_channel(portb, false, 8, "bit", 1.000, 0.0),
    # output_channel(porteh, false, 8, "bit", 1.000, 0.0),
    # output_channel(portk, false, 8, "bit", 1.000, 0.0),
    # output_channel(portmj, false, 8, "bit", 1.000, 0.0),
    # output_channel(portp, false, 8, "bit", 1.000, 0.0),
    # output_channel(portt, false, 8, "bit", 1.000, 0.0),
    # output_channel(cel_errorcode, false, 8, "bit", 1, 0.0),
    # output_channel(boost_targ_1, true, 16, "kPa", 0.1, 0),
    # output_channel(boost_targ_2, true, 16, "kPa", 0.1, 0),
    # output_channel(airtemp, true, 16, "�F", 0.100, 0.0),
    # output_channel(looptime, false, 16, "us", 1.0, 0.0),
    # output_channel(vss3, false, 16, "vss", 1.000, 0.0),
    # output_channel(vss4, false, 16, "vss", 1.000, 0.0),
    # output_channel(vss3_ms_1, false, 16, "ms-1", 0.1, 0.0),
    # output_channel(vss4_ms_1, false, 16, "ms-1", 0.1, 0.0),
    # output_channel(fuel_press1, true, 16, "kPa", 0.100, 0.0),
    # output_channel(fuel_press2, true, 16, "kPa", 0.100, 0.0),
    # output_channel(cl_idle_targ_rpm, false, 16, "rpm", 1, 0),
    # output_channel(fp_duty, false, 8, "%", 0.392, 0.0),
    # output_channel(alt_duty, false, 8, "%", 1, 0.0),
    # output_channel(alt_period, false, 8, "ms", 0.128, 0.0),
    # output_channel(load_duty, false, 8, "%", 1, 0.0),
    # output_channel(alt_targv, false, 8, "V", 0.100, 0.0),
    # output_channel(batt_curr, true, 16, "A", 0.1, 0.0),
    # output_channel(fueltemp_cor, true, 16, "%", 0.100, 0.0),
    # output_channel(fuelpress_cor, true, 16, "%", 0.100, 0.0),
    # output_channel(ltt_cor, true, 08, "%", 0.100, 0.0),
    # output_channel(engine_state, false, 8, "bit", 1, 0.0),
    # output_channel(tc_retard, true, 16, "deg", 0.100, 0.0),
    # output_channel(cel_retard, true, 16, "deg", 0.100, 0.0),
    # output_channel(fc_retard, true, 16, "deg", 0.100, 0.0),
    # output_channel(ext_advance, true, 16, "deg", 0.100, 0.0),
    # output_channel(base_advance, true, 16, "deg", 0.100, 0.0),
    # output_channel(idle_cor_advance, true, 16, "deg", 0.100, 0.0),
    # output_channel(mat_retard, true, 16, "deg", 0.100, 0.0),
    # output_channel(flex_advance, true, 16, "deg", 0.100, 0.0),
    # output_channel(adv1, true, 16, "deg", 0.100, 0.0),
    # output_channel(adv2, true, 16, "deg", 0.100, 0.0),
    # output_channel(adv3, true, 16, "deg", 0.100, 0.0),
    # output_channel(adv4, true, 16, "deg", 0.100, 0.0),
    # output_channel(revlim_retard, true, 16, "deg", 0.100, 0.0),
    # output_channel(als_timing, true, 16, "deg", 0.100, 0.0),
    # output_channel(als_addfuel, true, 16, "ms", 0.001, 0.0),
    # output_channel(deadtime1, true, 16, "ms", 0.001, 0.0),
    # output_channel(launch_timing, true, 16, "deg", 0.100, 0.0),
    # output_channel(step3_timing, true, 16, "deg", 0.100, 0.0),
    # output_channel(launchvss_retard, true, 16, "deg", 0.100, 0.0),
    # output_channel(cel_status2, false, 16, "bit", 1.000, 0.0),
    # output_channel(gps_latdeg, true, 08, "", 1, 0),
    # output_channel(gps_latmin, false, 8, "", 1, 0),
    # output_channel(gps_latmmin, false, 16, "", 1, 0),
    # output_channel(gps_londeg, false, 8, "", 1, 0),
    # output_channel(gps_lonmin, false, 8, "", 1, 0),
    # output_channel(gps_lonmmin, false, 16, "", 1, 0),
    # output_channel(gps_outstatus, false, 8, "", 1, 0),
    # output_channel(gps_altk, true, 08, "", 1, 0),
    # output_channel(gps_altm, true, 16, "", 0.1, 0),
    # output_channel(gps_speed, false, 16, "vss", 1.000, 0.0),
    # output_channel(gps_speed_ms_1, false, 16, "ms-1", 0.1, 0.0),
    # ???
    # output_channel(gps_course, false, 16, "", 0.1, 0),
    # output_channel(generic_pid_duty_a, false, 8, "%", 0.392, 0.0),
    # output_channel(generic_pid_duty_b, false, 8, "%", 0.392, 0.0),
    # output_channel(tc_slipxtime, false, 16, "", 1, 0),
    # output_channel(loop, false, 8, "", 1, 0),
    # output_channel(can_error_cnt, false, 8, "", 1, 0),
    # output_channel(can_error, false, 16, "", 1, 0),
    _::binary
  >>

  def engine(
        <<ready::size(1), crank::size(1), startw::size(1), warmup::size(1), tpsaen::size(1),
          tpsden::size(1), mapaen::size(1), mapden::size(1)>>
      ) do
    %{
      ready: bool(ready),
      crank: bool(crank),
      startw: bool(startw),
      warmup: bool(warmup),
      tpsaen: bool(tpsaen),
      tpsden: bool(tpsden),
      mapaen: bool(mapaen),
      mapden: bool(mapden)
    }
  end

  def squirt(
        <<firing1::size(1), firing2::size(1), sched1::size(1), inj1::size(1), sched2::size(1),
          inj2::size(1), _::bitstring>>
      ) do
    %{
      firing1: bool(firing1),
      firing2: bool(firing2),
      sched1: bool(sched1),
      inj1: bool(inj1),
      sched2: bool(sched2),
      inj2: bool(inj2)
    }
  end

  defp bool(1), do: true
  defp bool(0), do: false
end
