#
# AWSume Amazon Web Services profile manager
#

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_AWSUME_SHOW="${SPACESHIP_AWSUME_SHOW=true}"
SPACESHIP_AWSUME_PREFIX="${SPACESHIP_AWSUME_PREFIX="using "}"
SPACESHIP_AWSUME_SUFFIX="${SPACESHIP_AWSUME_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
SPACESHIP_AWSUME_SYMBOL="${SPACESHIP_AWSUME_SYMBOL="☁️ "}"
SPACESHIP_AWSUME_COLOR="${SPACESHIP_AWSUME_COLOR="208"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Shows selected AWSume profile.
spaceship_awsume() {
  [[ $SPACESHIP_AWSUME_SHOW == false ]] && return

  local profile=${AWSUME_PROFILE}

  # Is the current profile not the default profile
  [[ -z $profile ]] || [[ "$profile" == "default" ]] && return

  # Show prompt section
  spaceship::section \
    "$SPACESHIP_AWSUME_COLOR" \
    "$SPACESHIP_AWSUME_PREFIX" \
    "$SPACESHIP_AWSUME_SYMBOL$profile" \
    "$SPACESHIP_AWSUME_SUFFIX"
}