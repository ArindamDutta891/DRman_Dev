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

# Function to display the current version of a specified candidate or all candidates
function __drm_current() {
    local candidate="$1"
    
    echo ""

    # If a specific candidate is provided
    if [ -n "$candidate" ]; then
        __drman_determine_current_version "$candidate"
        if [ -n "$CURRENT" ]; then
            __drman_echo_no_colour "Using ${candidate} version ${CURRENT}"
        else
            __drman_echo_red "Not using any version of ${candidate}"
        fi
    else
        # If no specific candidate is provided, iterate over all candidates
        local installed_count=0
        for candidate in "${DRMAN_CANDIDATES[@]}"; do
            # Skip empty entries due to incompatibility
            if [ -n "$candidate" ]; then
                __drman_determine_current_version "$candidate"
                if [ -n "$CURRENT" ]; then
                    if [ $installed_count -eq 0 ]; then
                        __drman_echo_no_colour 'Using:'
                        echo ""
                    fi
                    __drman_echo_no_colour "${candidate}: ${CURRENT}"
                    ((installed_count++))
                fi
            fi
        done

        # If no candidates are in use
        if [ $installed_count -eq 0 ]; then
            __drman_echo_no_colour 'No candidates are in use'
        fi
    fi
}

# Function to determine the current version of a specified candidate
function __drman_determine_current_version() {
    local candidate="$1"
    local present

    # Check if the candidate directory exists in DRMAN_CANDIDATES_DIR
    present=$(__drman_path_contains "${DRMAN_CANDIDATES_DIR}/${candidate}")

    if [[ "$present" == 'true' ]]; then
        # Use appropriate command based on the operating system
        if [[ "$solaris" == true ]]; then
            CURRENT=$(echo "$PATH" | gsed -r "s|${DRMAN_CANDIDATES_DIR}/${candidate}/([^/]+)/bin|!!\1!!|1" | gsed -r "s|^.*!!(.+)!!.*$|\1|g")
        elif [[ "$darwin" == true ]]; then
            CURRENT=$(echo "$PATH" | sed -E "s|${DRMAN_CANDIDATES_DIR}/${candidate}/([^/]+)/bin|!!\1!!|1" | sed -E "s|^.*!!(.+)!!.*$|\1|g")
        else
            CURRENT=$(echo "$PATH" | sed -r "s|${DRMAN_CANDIDATES_DIR}/${candidate}/([^/]+)/bin|!!\1!!|1" | sed -r "s|^.*!!(.+)!!.*$|\1|g")
        fi

        # Resolve symbolic link if the current version is set to "current"
        if [[ "$CURRENT" == "current" ]]; then
            CURRENT=$(readlink "${DRMAN_CANDIDATES_DIR}/${candidate}/current" | sed "s!${DRMAN_CANDIDATES_DIR}/${candidate}/!!g")
        fi
    else
        CURRENT=""  # Reset CURRENT if candidate is not present
    fi
}

# Example of how to use the script:
# __drm_current "my_candidate"   # To display version for a specific candidate
# __drm_current                   # To display versions for all candidates
