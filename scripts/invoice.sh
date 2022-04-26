#!/bin/bash

############################################################################################################################
#### This script will handle generating automatic PDF invoice using omarahm3/invoice-generator on 27th day of each month
#### Script must be ran with the `-s` option with the path to omarahm3/invoice-generator directory (path must be absolute)
#### For example ./invoice.sh -s ~/.projectjs/invoice-generator
############################################################################################################################

DEFAULT_MONTH_NUMBER=$(date +%m)
YARN_GENERATE_COMMAND="yarn run generate"
YARN_PDF_COMMAND="yarn run pdf"
DEFAULT_LOG_FILE="/home/mrgeek/.mrg-invoice-generator.log"

log ()
{
  echo "$(date '+%Y-%m-%d %I-%m-%S'):: $1" | tee -a $DEFAULT_LOG_FILE
}

parse_month_number ()
{
  month=$1
  if [ "${month:0:1}" = "0" ]; then
    echo "${month:1:1}"
    return
  fi
  echo "${month}"
}

generate_invoice ()
{
  month=$(parse_month_number $1)
  location=$2
  
  invoice_command="yarn --cwd $location run generate $month 0 2>&1 >> $DEFAULT_LOG_FILE"
  log "Running command: $invoice_command"
  eval $invoice_command 2>&1 >>$DEFAULT_LOG_FILE
  log "Invoice html is generated"

  pdf_command="yarn --cwd $location run pdf 2>&1 >> $DEFAULT_LOG_FILE"
  log "Running command: $pdf_command"
  eval $pdf_command 2>&1 >>$DEFAULT_LOG_FILE
  log "Invoice PDF is generated"

  DISPLAY=:0.0 notify-send -u critical -i "Invoice Generator" "Invoice $month is ready to be sent"
}

while getopts s:m:f: flag
do
  case "${flag}" in
    s) script_location=${OPTARG};;
  esac
done

log "Generating new invoice ($DEFAULT_MONTH_NUMBER)"
generate_invoice $DEFAULT_MONTH_NUMBER $script_location
log "Invoice generated"
