#
# Conda
#
# Package, dependency and environment management for any language
# Link: https://conda.io/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_CONDA_SHOW="${SPACESHIP_CONDA_SHOW=true}"
SPACESHIP_CONDA_PREFIX="${SPACESHIP_CONDA_PREFIX="$SPACESHIP_PROMPT_DEFAULT_PREFIX"}"
SPACESHIP_CONDA_SUFFIX="${SPACESHIP_CONDA_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
SPACESHIP_CONDA_SYMBOL="${SPACESHIP_CONDA_SYMBOL="🅒 "}"
SPACESHIP_CONDA_COLOR="${SPACESHIP_CONDA_COLOR="blue"}"
SPACESHIP_CONDA_VERBOSE="${SPACESHIP_CONDA_VERBOSE=true}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current conda virtual environment
 spaceship_condav() {
  [[ $SPACESHIP_CONDA_SHOW == false ]] && return

  # Check if running via conda virtualenv
  spaceship::exists conda && [ -n "$CONDA_DEFAULT_ENV" ] || return

  # Dont show information in the base env
  [[ $CONDA_DEFAULT_ENV == "base" ]] && return

  local conda_env=${CONDA_DEFAULT_ENV}

  if [[ $SPACESHIP_CONDA_VERBOSE == false ]]; then
    conda_env=${CONDA_DEFAULT_ENV:t}
  fi

  local python_version=$(python --version | sed "s/^[^ ]* //")

  spaceship::section \
    "$SPACESHIP_CONDA_COLOR" \
    "$SPACESHIP_CONDA_PREFIX" \
    "${SPACESHIP_CONDA_SYMBOL}${conda_env}:${python_version}" \
    "$SPACESHIP_CONDA_SUFFIX"
}