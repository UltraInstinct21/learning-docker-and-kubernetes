# Topic 04: CMD vs. ENTRYPOINT

## 1. Overview & Core Differences

Both `CMD` and `ENTRYPOINT` define what runs when a container starts, but they behave very differently when arguments are passed at runtime:

| Feature | `CMD` | `ENTRYPOINT` |
| :--- | :--- | :--- |
| **Purpose** | Sets **default arguments** or command | Sets the **fixed executable binary** |
| **Overriding via CLI** | Easily overridden by appending arguments to `docker run` | Must use `--entrypoint` flag to override |
| **CLI Arguments Behavior** | CLI args **replace** the entire `CMD` | CLI args **append** to the `ENTRYPOINT` |

---

## 2. Deep Dive: Three Core Patterns

### Pattern A: `CMD` Alone
```dockerfile
FROM alpine:3.20
CMD ["echo", "Hello from CMD"]
```
- **Default run**:
  ```bash
  docker run my-image
  # Output: Hello from CMD
  ```
- **CLI Override**:
  ```bash
  docker run my-image date
  # Output: Mon Aug 10 16:30:00 UTC 2026
  # The entire `echo "Hello from CMD"` was replaced by `date`.
  ```

---

### Pattern B: `ENTRYPOINT` Alone
```dockerfile
FROM alpine:3.20
ENTRYPOINT ["echo", "Hello from ENTRYPOINT"]
```
- **Default run**:
  ```bash
  docker run my-image
  # Output: Hello from ENTRYPOINT
  ```
- **With CLI arguments**:
  ```bash
  docker run my-image "Extra Argument"
  # Output: Hello from ENTRYPOINT Extra Argument
  # The CLI argument was APPENDED to the entrypoint array.
  ```

---

### Pattern C: Combining `ENTRYPOINT` + `CMD` (Industry Best Practice)
In this pattern:
- `ENTRYPOINT` defines the permanent executable command.
- `CMD` provides the default parameter(s) that can be easily customized.

```dockerfile
FROM alpine:3.20
# Fixed executable binary
ENTRYPOINT ["ping"]
# Default parameters (overridable)
CMD ["localhost"]
```

- **Default Execution**:
  ```bash
  docker run my-ping-tool
  # Runs: ping localhost
  ```
- **Custom Target Execution**:
  ```bash
  docker run my-ping-tool google.com
  # Runs: ping google.com (only the default "localhost" parameter was replaced!)
  ```

---

## 3. How Docker Combines ENTRYPOINT and CMD

```
+---------------------------+   +-------------------+   +--------------------+
| ENTRYPOINT ["node"]       | + | CMD ["server.js"] | = | node server.js     |
+---------------------------+   +-------------------+   +--------------------+

If user runs: `docker run my-image app.js`
+---------------------------+   +-------------------+   +--------------------+
| ENTRYPOINT ["node"]       | + | CLI ["app.js"]    | = | node app.js        |
+---------------------------+   +-------------------+   +--------------------+
```

---

## 4. Useful CLI Commands

```bash
# Running container with CMD override
docker run --rm alpine:3.20 uname -r

# Forcing ENTRYPOINT override when needed
docker run --rm --entrypoint /bin/sh my-image -c "ls -la /app"
```
