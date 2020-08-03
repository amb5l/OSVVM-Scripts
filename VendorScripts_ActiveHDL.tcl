#  File Name:         VendorScripts_Mentor.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    Tcl procedures with the intent of making running 
#    compiling and simulations tool independent
#    
#  Developed by: 
#        SynthWorks Design Inc. 
#        VHDL Training Classes
#        OSVVM Methodology and Model Library
#        11898 SW 128th Ave.  Tigard, Or  97223
#        http://www.SynthWorks.com
# 
#  Revision History:
#    Date      Version    Description
#    11/2018   Alpha      Project descriptors in .files and .dirs files
#     2/2019   Beta       Project descriptors in .pro which execute 
#                         as TCL scripts in conjunction with the library 
#                         procedures
#     1/2020   2020.01    Updated Licenses to Apache
#     7/2020   2020.07    Refactored for simpler vendor customization
#     7/2020   2020.07    Refactored tool execution for simpler vendor customization
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2018 - 2020 by SynthWorks Design Inc.  
#  
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#  
#      https://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#


# -------------------------------------------------
# StartTranscript / StopTranscxript
#
proc vendor_StartTranscript {FileName} {
  transcript off
  echo transcript to $FileName
  transcript to $FileName
}

proc vendor_StopTranscript {FileName} {
  transcript off
}


# -------------------------------------------------
# Library
#
proc vendor_library {LibraryName PathToLib} {
  set MY_START_DIR [pwd]

  set PathAndLib ${PathToLib}/${LibraryName}

  if {![file exists ${PathAndLib}]} {
    echo design create -a  $LibraryName ${PathToLib}
    design create -a  $LibraryName ${PathToLib}
  }
  echo design open -a  ${PathAndLib}
  design open -a  ${PathAndLib}
  design activate $LibraryName
  cd ${PathAndLib}
  if {![file exists results]} {
    file link -symbolic results ${MY_START_DIR}/results  
  }
  cd $MY_START_DIR
}


proc vendor_map {LibraryName ResolvedPathToLib} {
  set MY_START_DIR [pwd]
  set PathAndLib ${PathToLib}/${LibraryName}

  if {![file exists ${PathAndLib}]} {
    error "Map:  Creating library ${ResolvedPathToLib} since it does not exist.  "
    echo design create -a  $LibraryName ${PathToLib}
    design create -a  $LibraryName ${PathToLib}
  }
  echo design open -a  ${PathAndLib}
  design open -a  ${PathAndLib}
  
  design activate $LibraryName
  cd $MY_START_DIR
}

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName} {
  global DIR_LIB
  
  set MY_START_DIR [pwd]
  set FileBaseName [file rootname [file tail $FileName]]
  
  # Check src to see if it has been added
  if {![file isfile ${DIR_LIB}/$LibraryName/src/${FileBaseName}.vcom]} {
    echo addfile ${FileName}
    addfile ${FileName}
    filevhdloptions -2008 ${FileName}
  }
  # Compile it.
  echo vcom -2008 -dbg -relax -work ${LibraryName} ${FileName} 
  echo vcom -2008 -dbg -relax -work ${LibraryName} ${FileName} > ${DIR_LIB}/$LibraryName/src/${FileBaseName}.vcom
  vcom -2008 -dbg -relax -work ${LibraryName} ${FileName}
  
  cd $MY_START_DIR
}

proc vendor_analyze_verilog {LibraryName FileName} {
  set MY_START_DIR [pwd]

#  Untested branch for Verilog - will need adjustment
#  Untested branch for Verilog - will need adjustment
    echo vlog -work ${LibraryName} ${FileName}
    vlog -work ${LibraryName} ${FileName}
  cd $MY_START_DIR
}

# -------------------------------------------------
# Simulate
#
proc vendor_simulate {LibraryName LibraryUnit OptionalCommands} {
  set MY_START_DIR [pwd]

  echo vsim -t $::SIMULATE_TIME_UNITS -lib ${LibraryName} ${LibraryUnit} ${OptionalCommands} 
  vsim -t $::SIMULATE_TIME_UNITS -lib ${LibraryName} ${LibraryUnit} ${OptionalCommands} 
  
  cd $MY_START_DIR
  if {[file exists ${LibraryUnit}.tcl]} {
    source ${LibraryUnit}.tcl
  }
  cd $MY_START_DIR
  if {[file exists ${LibraryUnit}_$::simulator.tcl]} {
    source ${LibraryUnit}_$::simulator.tcl
  }
  cd $MY_START_DIR
  if {[file exists ${LibraryUnit}_$::simulator.tcl]} {
    source ${LibraryUnit}_$::simulator.tcl
  }
  cd $MY_START_DIR
#  do $::SCRIPT_DIR/Mentor.do
#  add log -r /*
  run -all 
  cd $MY_START_DIR
}