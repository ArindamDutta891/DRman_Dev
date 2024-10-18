# Function to present a menu for selecting a DID method
function __drm_did() {
    PS3='Please choose a DID method: '  # Prompt for user input
    options=("did:sov" "did:git" "Quit")  # Available options

    select opt in "${options[@]}"; do
        case $opt in
            "did:sov")
                # Call the script for did:sov method
                $DRMAN_PLUGINS_DIR/DID/did-sov.sh
                ;;
            "did:git")
                # Call the script for did:git method
                $DRMAN_PLUGINS_DIR/DID/did-git.sh               
                ;;
            "Quit")
                # Exit the menu
                exit 0
                ;;
            *)
                echo "Invalid option $REPLY; please try again."  # Handle invalid option
                ;;
        esac
    done
}
