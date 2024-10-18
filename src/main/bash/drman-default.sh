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

# Function to set the default version of a specified candidate
function __drm_default() {
    local candidate="$1"
    local version="$2"

    # Check if the candidate is present; if not, return with an error
    __drman_check_candidate_present "$candidate" || return 1
    
    # Determine the version to set; return if it fails
    __drman_determine_version "$candidate" "$version" || return 1

    # Check if the specified version directory exists
    if [ ! -d "${DRMAN_CANDIDATES_DIR}/${candidate}/${VERSION}" ]; then
        echo ""
        __drman_echo_red "Stop! ${candidate} ${VERSION} is not installed."
        return 1
    fi

    # Link the specified candidate version as the default
    __drman_link_candidate_version "$candidate" "$VERSION"

    echo ""
    __drman_echo_green "Default ${candidate} version set to ${VERSION}"
}

# Example of how to use the function:
# __drm_default "my_candidate" "1.0.0"  # To set a specific version as default
