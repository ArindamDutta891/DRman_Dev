#!/usr/bin/env bash

#
#   Copyright 2020 the original author or authors.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

# Function to flush specified components of the DRMAN environment
function __drm_flush() {
    local qualifier="$1"

    case "$qualifier" in
        broadcast)
            if [[ -f "${DRMAN_DIR}/var/broadcast_id" ]]; then
                rm -f "${DRMAN_DIR}/var/broadcast_id" "${DRMAN_DIR}/var/broadcast"
                __drman_echo_green "Broadcast has been flushed."
            else
                __drman_echo_no_colour "No prior broadcast found so not flushed."
            fi
            ;;
        version)
            if [[ -f "${DRMAN_DIR}/var/version" ]]; then
                rm -f "${DRMAN_DIR}/var/version"
                __drman_echo_green "Version file has been flushed."
            else
                __drman_echo_no_colour "No version file found so not flushed."
            fi
            ;;
        archives|temp|tmp)
            __drman_cleanup_folder "$qualifier"
            ;;
        *)
            __drman_echo_red "Stop! Please specify what you want to flush."
            ;;
    esac
}

# Function to clean up a specified folder
function __drman_cleanup_folder() {
    local folder="$1"
    local cleanup_dir="${DRMAN_DIR}/${folder}"
    
    # Get the disk usage and count of items before cleanup
    local cleanup_disk_usage=$(du -sh "$cleanup_dir" 2>/dev/null)
    local cleanup_count=$(find "$cleanup_dir" -mindepth 1 -maxdepth 1 | wc -l)

    # Clean up the folder
    rm -rf "$cleanup_dir"
    mkdir -p "$cleanup_dir"

    # Report the cleanup results
    __drman_echo_green "${cleanup_count} archive(s) flushed, freeing ${cleanup_disk_usage}."
}
