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

# Function to load candidate versions from the .drmanrc file
function __drm_env() {
    readonly drmanrc='.drmanrc'

    # Check if the .drmanrc file exists
    if [[ ! -f "$drmanrc" ]]; then
        __drman_echo_red "No $drmanrc file found."
        echo ""
        __drman_echo_yellow "Please create one before using this command."
        return 1
    fi

    local line_number=0

    # Read the .drmanrc file line by line
    while IFS= read -r line || [[ -n $line ]]; do
        # Validate the format of each line
        if [[ ! $line =~ ^[[:lower:]]+=.+$ ]]; then
            __drman_echo_red "${drmanrc}:${line_number}: Invalid candidate format! Expected 'candidate=version' but found '$line'"
            return 1
        fi

        # Extract candidate and version, then use them
        __drm_use "${line%=*}" "${line#*=}"

        ((line_number++))  # Increment line number for error reporting
    done < "$drmanrc"  # Read from the .drmanrc file
}
