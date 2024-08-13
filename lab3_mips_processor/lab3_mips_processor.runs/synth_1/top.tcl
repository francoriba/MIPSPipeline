# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
namespace eval ::optrace {
  variable script "/home/franco/Desktop/arqui/MIPSPipeline/lab3_mips_processor/lab3_mips_processor.runs/synth_1/top.tcl"
  variable category "vivado_synth"
}

# Try to connect to running dispatch if we haven't done so already.
# This code assumes that the Tcl interpreter is not using threads,
# since the ::dispatch::connected variable isn't mutex protected.
if {![info exists ::dispatch::connected]} {
  namespace eval ::dispatch {
    variable connected false
    if {[llength [array get env XILINX_CD_CONNECT_ID]] > 0} {
      set result "true"
      if {[catch {
        if {[lsearch -exact [package names] DispatchTcl] < 0} {
          set result [load librdi_cd_clienttcl[info sharedlibextension]] 
        }
        if {$result eq "false"} {
          puts "WARNING: Could not load dispatch client library"
        }
        set connect_id [ ::dispatch::init_client -mode EXISTING_SERVER ]
        if { $connect_id eq "" } {
          puts "WARNING: Could not initialize dispatch client"
        } else {
          puts "INFO: Dispatch client connection id - $connect_id"
          set connected true
        }
      } catch_res]} {
        puts "WARNING: failed to connect to dispatch server - $catch_res"
      }
    }
  }
}
if {$::dispatch::connected} {
  # Remove the dummy proc if it exists.
  if { [expr {[llength [info procs ::OPTRACE]] > 0}] } {
    rename ::OPTRACE ""
  }
  proc ::OPTRACE { task action {tags {} } } {
    ::vitis_log::op_trace "$task" $action -tags $tags -script $::optrace::script -category $::optrace::category
  }
  # dispatch is generic. We specifically want to attach logging.
  ::vitis_log::connect_client
} else {
  # Add dummy proc if it doesn't exist.
  if { [expr {[llength [info procs ::OPTRACE]] == 0}] } {
    proc ::OPTRACE {{arg1 \"\" } {arg2 \"\"} {arg3 \"\" } {arg4 \"\"} {arg5 \"\" } {arg6 \"\"}} {
        # Do nothing
    }
  }
}

proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
OPTRACE "synth_1" START { ROLLUP_AUTO }
set_param checkpoint.writeSynthRtdsInDcp 1
set_param synth.incrementalSynthesisCache ./.Xil/Vivado-2915263-franco-desktop/incrSyn
set_msg_config -id {Synth 8-256} -limit 10000
set_msg_config -id {Synth 8-638} -limit 10000
OPTRACE "Creating in-memory project" START { }
create_project -in_memory -part xc7a35tcpg236-3

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir /home/franco/Desktop/arqui/MIPSPipeline/lab3_mips_processor/lab3_mips_processor.cache/wt [current_project]
set_property parent.project_path /home/franco/Desktop/arqui/MIPSPipeline/lab3_mips_processor/lab3_mips_processor.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo /home/franco/Desktop/arqui/MIPSPipeline/lab3_mips_processor/lab3_mips_processor.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
OPTRACE "Creating in-memory project" END { }
OPTRACE "Adding files" START { }
read_verilog {
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/common/common.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/utils/inc/adder.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/common/codes.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/ex/inc/alu_control.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/ex/inc/alu.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/mem/inc/data_memory.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/debugger/inc/debugger.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/debugger/inc/debugger_control.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/ex/inc/ex.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/mem/inc/mem.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/pipeline/inc/ex_mem.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/uart/inc/fifo.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/id/inc/registers_bank.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/id/inc/id.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/utils/inc/sig_extend.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/id/inc/main_control.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/utils/inc/unsig_extend.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/if/inc/pc.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/pipeline/inc/id_ex.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/if/inc/instruction_memory.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/if/inc/if.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/pipeline/inc/if_id.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/utils/inc/is_not_equal.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/utils/inc/is_zero.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/wb/inc/wb.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/pipeline/inc/mem_wb.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/debugger/inc/memory_printer.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/mips.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/utils/inc/mux.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/debugger/inc/register_printer.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/hazard/inc/risk_detection.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/utils/inc/shift_left.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/hazard/inc/short_circuit.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/uart/inc/uart.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/uart/inc/uart_brg.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/debugger/inc/uart_reader.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/uart/inc/uart_tx_rx.vh
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/debugger/inc/uart_writer.vh
}
read_verilog -library xil_defaultlib {
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/utils/src/adder.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/ex/src/alu.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/ex/src/alu_control.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/mem/src/data_memory.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/debugger/src/debugger.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/debugger/src/debugger_control.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/ex/src/ex.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/pipeline/src/ex_mem.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/uart/src/fifo.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/id/src/id.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/pipeline/src/id_ex.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/if/src/if.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/pipeline/src/if_id.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/if/src/instruction_memory.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/utils/src/is_not_equal.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/utils/src/is_zero.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/id/src/main_control.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/mem/src/mem.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/pipeline/src/mem_wb.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/debugger/src/memory_printer.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/mips.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/utils/src/mux.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/if/src/pc.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/debugger/src/register_printer.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/id/src/registers_bank.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/hazard/src/risk_detection.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/utils/src/shift_left.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/hazard/src/short_circuit.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/utils/src/sig_extend.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/uart/src/uart.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/uart/src/uart_brg.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/debugger/src/uart_reader.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/uart/src/uart_rx.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/uart/src/uart_tx.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/debugger/src/uart_writer.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/utils/src/unsig_extend.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/mips/wb/src/wb.v
  /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/sources/top.v
}
OPTRACE "Adding files" END { }
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/constrs/Basys-3-Master.xdc
set_property used_in_implementation false [get_files /home/franco/Desktop/arqui/ARQ_ICOMP_2023-TP_FINAL/vivado.src/constrs/Basys-3-Master.xdc]

set_param ips.enableIPCacheLiteLoad 1

read_checkpoint -auto_incremental -incremental /home/franco/Desktop/arqui/MIPSPipeline/lab3_mips_processor/lab3_mips_processor.srcs/utils_1/imports/synth_1/top.dcp
close [open __synthesis_is_running__ w]

OPTRACE "synth_design" START { }
synth_design -top top -part xc7a35tcpg236-3
OPTRACE "synth_design" END { }
if { [get_msg_config -count -severity {CRITICAL WARNING}] > 0 } {
 send_msg_id runtcl-6 info "Synthesis results are not added to the cache due to CRITICAL_WARNING"
}


OPTRACE "write_checkpoint" START { CHECKPOINT }
# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef top.dcp
OPTRACE "write_checkpoint" END { }
OPTRACE "synth reports" START { REPORT }
create_report "synth_1_synth_report_utilization_0" "report_utilization -file top_utilization_synth.rpt -pb top_utilization_synth.pb"
OPTRACE "synth reports" END { }
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
OPTRACE "synth_1" END { }