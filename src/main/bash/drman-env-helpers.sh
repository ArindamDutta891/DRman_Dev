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

# Function to check if a candidate is provided
function __drman_check_candidate_present() {
    local candidate="$1"

    if [ -z "$candidate" ]; then
        echo ""
        __drman_echo_red "No candidate provided."
        __drm_help  # Display help if no candidate is provided
        return 1
    fi
}

# Function to check if a version is provided
function __drman_check_version_present() {
    local version="$1"

    if [ -z "$version" ]; then
        echo ""
        __drman_echo_red "No candidate version provided."
        __drm_help  # Display help if no version is provided
        return 1
    fi
}

# Function to determine the version of a candidate
function __drman_determine_version() {
    local candidate="$1"
    local version="$2"
    local folder="$3"

    # Check availability and directory structure based on conditions
    if [[ "$DRMAN_AVAILABLE" == "false" && -n "$version" && -d "${DRMAN_CANDIDATES_DIR}/${candidate}/${version}" ]]; then
        VERSION="$version"

    elif [[ "$DRMAN_AVAILABLE" == "false" && -z "$version" && -L "${DRMAN_CANDIDATES_DIR}/${candidate}/current" ]]; then
        VERSION=$(readlink "${DRMAN_CANDIDATES_DIR}/${candidate}/current" | sed "s!${DRMAN_CANDIDATES_DIR}/${candidate}/!!g")

    elif [[ "$DRMAN_AVAILABLE" == "false" && -n "$version" ]]; then
        __drman_echo_red "Stop! ${candidate} ${version} is not available while offline."
        return 1

    elif [[ "$DRMAN_AVAILABLE" == "false" && -z "$version" ]]; then
        __drman_echo_red "This command is not available while offline."
        return 1

    else
        # If version is not specified, fetch it
        if [[ -z "$version" ]]; then
            version=$(__drman_secure_curl "${DRMAN_CANDIDATES_API}/candidates/default/${candidate}")
        fi

        local validation_url="${DRMAN_CANDIDATES_API}/candidates/validate/${candidate}/${version}/$(echo $DRMAN_PLATFORM | tr '[:upper:]' '[:lower:]')"
        VERSION_VALID=$(__drman_secure_curl "$validation_url")

        __drman_echo_debug "Validate $candidate $version for $DRMAN_PLATFORM: $VERSION_VALID"
        __drman_echo_debug "Validation URL: $validation_url"

        # Check validation results
        if [[ "$VERSION_VALID" == 'valid' || ("$VERSION_VALID" == 'invalid' && -n "$folder") ]]; then
            VERSION="$version"

        elif [[ "$VERSION_VALID" == 'invalid' && (-L "${DRMAN_CANDIDATES_DIR}/${candidate}/${version}" || -d "${DRMAN_CANDIDATES_DIR}/${candidate}/${version}") ]]; then
            VERSION="$version"

        else
            # Handle the case where the version is not valid
            if [[ -z "$version" ]]; then
                version="\b"  # Assign a default value for further checks
            fi

            echo ""
            __drman_echo_red "Stop! $candidate $version is not available. Possible causes:"
            __drman_echo_red " * $version is an invalid version"
            __drman_echo_red " * $candidate binaries are incompatible with $DRMAN_PLATFORM"
            __drman_echo_red " * $candidate has not been released yet"
            return 1
        fi
    fi
}
