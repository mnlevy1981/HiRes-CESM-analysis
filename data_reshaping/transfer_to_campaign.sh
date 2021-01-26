#!/bin/bash

# Generate a file list to use with global transfer --batch
gen_file_list() {
  # Inputs:
  #   $1: directory on glade to list files from
  #   $2: filter to apply to file list (e.g. *.log.*)
  #   $3: optional text for each line (e.g. --recursive)
  # Output:
  #   globus_transfer_list.txt is formatted for globus transfer --batch
  for file in `globus ls --filter "~$2" ${GLADE}:$1`
  do
    if [ "$3" == "" ]; then
      echo $file $file
    else
      echo $file $file $3
    fi
  done > globus_transfer_list.txt
}

################

# Function to call globus transfer given label, source location,
# dest location, and possibly additional arguments
transfer() {
  # Inputs
  #   $1: label for transfer
  #   $2: source location (on glade)
  #   $3: dest location (on campaign)
  #   $4: additional opts (optional)
  echo "Submitting transfer from $2 to $3"
  label=${1//./_} # replace . with _ for label
  echo ${label}
  globus transfer $OPTS $4 --label $label ${GLADE}:$2 ${CAMPAIGN}:$3 < globus_transfer_list.txt
  rm globus_transfer_list.txt
}

################

# Function to wrap call to transfer() when sending time series
# files to campaign (since location on disk is formulaic)
transfer_ts() {
  # Inputs
  #   $1: component (ocn or ice)
  #   $2: stream name (e.g. pop.h)
  #   $3: frequency (e.g. month_1)
  gen_file_list ${TIMESERIES_ROOT}/$2/proc/COMPLETED "*.$2*.nc"
  transfer $2 ${TIMESERIES_ROOT}/$2/proc/COMPLETED ${CAMPAIGN_ROOT}/$1/proc/tseries/$3
}


################
#  MAIN SCRIPT #
################

# 1. check to see if globus=cli is installed
GLOBUS_FOUND=FALSE
globus --version > /dev/null 2>&1 && GLOBUS_FOUND=TRUE

if [ "${GLOBUS_FOUND}" == "FALSE" ]; then
  echo "Can not find globus-cli!"
  exit 1
fi

# 2. set up endpoints and directories
GLADE="d33b3614-6d04-11e5-ba46-22000b92c6ec"
CAMPAIGN="6b5ab960-7bbf-11e8-9450-0a6d4e044368"
GLADE_ARCHIVE=/glade/scratch/mlevy/archive/g.e22.G1850ECO_JRA_HR.TL319_t13.004
CAMPAIGN_ROOT=/glade/campaign/cesm/development/bgcwg/projects/hi-res_JRA/cases/g.e22.G1850ECO_JRA_HR.TL319_t13.004/output
TIMESERIES_ROOT=/glade/scratch/mlevy/T13/g.e22.G1850ECO_JRA_HR.TL319_t13.004

# 3. Activate globus
cmd="globus endpoint activate --web ${GLADE}"
echo "Activating globus..."
echo "\$ ${cmd}"
${cmd}
read -p "Log in to globus via the above URL then press enter to continue..."

# 4. Save options for globus transfer
#    - replace file if checksum has changed
#    - date stamp should match what is on glade
#    - verify transfer was successful via checksum
#    - email me when transfer is done
#    - batch job (will pass a list of files via stdin)
# NOTE: will also use --label to name different transfers
OPTS="--sync-level checksum --preserve-mtime --verify-checksum --notify on --batch"

# 5. Actual transfers
#    i. time series netCDF
#       * POP monthly
transfer_ts ocn pop.h month_1
#       * POP daily
transfer_ts ocn pop.h.nday1 day_1
#       * POP annual
transfer_ts ocn pop.h.nyear1 year_1
#       * CICE monthly
transfer_ts ice cice.h month_1
#       * CICE daily
transfer_ts ice cice.h1 day_1

#    ii. restart files
#        NOTE: file list requires --recursive to copy directories
#subdir=rest
#gen_file_list ${GLADE_ARCHIVE}/${subdir} "*-[01][12]-01*" --recursive
#transfer $subdir ${GLADE_ARCHIVE}/${subdir} ${CAMPAIGN_ROOT}/${subdir}

#    iii. pop.d files
subdir=ocn/hist
gen_file_list ${GLADE_ARCHIVE}/${subdir} "*.pop.d*"
transfer "pop.d" ${GLADE_ARCHIVE}/${subdir} ${CAMPAIGN_ROOT}/${subdir}

#    iv. logs
subdir=logs
gen_file_list ${GLADE_ARCHIVE}/${subdir} "*.log.*"
transfer $subdir ${GLADE_ARCHIVE}/${subdir} ${CAMPAIGN_ROOT}/${subdir}
