# ==============================================================================
# THEORY: USING CMD ALONE
# ==============================================================================
# `CMD` sets the default command and parameters to execute when a container starts.
#
# CHARACTERISTICS:
# - Easily overridden: Any argument passed after the image name in `docker run`
#   completely replaces the entire `CMD` instruction.
#
# EXAMPLE:
# - Default: `docker run my-cmd-image` -> Runs `echo "Hello World from Docker"`
# - Override: `docker run my-cmd-image date` -> Runs `date` (the whole echo is replaced)
#
# USEFUL DOCKER CLI COMMANDS:
# ------------------------------------------------------------------------------
# 1. Build this image:
#    docker build -t test-cmd -f Dockerfile.cmd .
#
# 2. Run with default CMD:
#    docker run --rm test-cmd
#    # Output: Hello World from Docker
#
# 3. Override entire command by passing a new command:
#    docker run --rm test-cmd uname -a
#    # Output: Linux ... (executes uname instead of echo)
# ==============================================================================

FROM alpine:3.20

# Exec form of CMD
CMD ["echo", "Hello World from Docker"]
