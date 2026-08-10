# ==============================================================================
# THEORY: COMBINING ENTRYPOINT AND CMD (THE BEST PRACTICE PATTERN)
# ==============================================================================
# When ENTRYPOINT and CMD are used together in exec form:
# - `ENTRYPOINT`: Defines the fixed executable / binary that will run.
# - `CMD`: Defines the default arguments passed to that ENTRYPOINT executable.
#
# BEHAVIOR:
# 1. Running without extra arguments:
#    `docker run my-app`
#    Executes: `echo "DEFAULT MESSAGE"`
#
# 2. Running with CLI arguments:
#    `docker run my-app "Custom Argument Passed"`
#    Executes: `echo "Custom Argument Passed"` (CMD is replaced by the CLI arguments!)
#
# 3. Overriding the ENTRYPOINT entirely:
#    `docker run --entrypoint /bin/sh my-app`
#
# USEFUL DOCKER CLI COMMANDS:
# ------------------------------------------------------------------------------
# 1. Build this image:
#    docker build -t echo-app:combined .
#
# 2. Test default behavior (uses CMD):
#    docker run --rm echo-app:combined
#    # Output: DEFAULT MESSAGE
#
# 3. Test overriding default arguments (replaces CMD):
#    docker run --rm echo-app:combined "Hello from terminal override!"
#    # Output: Hello from terminal override!
#
# 4. Test overriding ENTRYPOINT:
#    docker run --rm --entrypoint date echo-app:combined
# ==============================================================================

FROM alpine:3.20

# Fixed executable
ENTRYPOINT ["echo"]

# Default parameter (can be easily overridden at runtime)
CMD ["DEFAULT MESSAGE"]