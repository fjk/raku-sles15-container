FROM --platform=linux/amd64 opensuse/leap:15.5

# Basis-Tools
RUN zypper -n ref && \
    zypper -n in --no-recommends curl git perl make gcc ca-certificates wget tar gzip && \
    zypper clean -a

# Rakubrew + aktuelles Rakudo + zef für root installieren
RUN curl -s https://rakubrew.org/install-on-perl.sh -o /tmp/install-on-perl.sh && \
    bash /tmp/install-on-perl.sh && \
    /root/.rakubrew/bin/rakubrew mode shim && \
    RAKUBREW_MODE=shim /root/.rakubrew/bin/rakubrew download moar && \
    RAKUBREW_MODE=shim /root/.rakubrew/bin/rakubrew build-zef && \
    rm -f /tmp/install-on-perl.sh

# PATH setzen, damit raku & rakubrew direkt verfügbar sind
ENV PATH="/root/.rakubrew/shims:/root/.rakubrew/bin:${PATH}"

# Copy module configuration into the image
COPY modules.conf /root/modules.conf

# ---------------------------------------------------------------------------
# Install Raku modules listed in /root/modules.conf using zef
RUN sh -lc '\
  if [ -f /root/modules.conf ]; then \
    echo "Installing Raku modules from modules.conf:"; \
    modules=$(grep -Ev "^[[:space:]]*#|^[[:space:]]*$" /root/modules.conf || true); \
    if [ -n "$modules" ]; then \
      echo "$modules"; \
      ZEF=/root/.rakubrew/shims/zef; \
      if [ ! -x "$ZEF" ]; then \
        echo "ERROR: zef not found at $ZEF"; \
        exit 1; \
      fi; \
      echo "$modules" | xargs -r "$ZEF" install --/test; \
    else \
      echo "No modules to install (modules.conf is empty or only comments)."; \
    fi; \
  else \
    echo "No /root/modules.conf found, skipping Raku module installation."; \
  fi'

# ---------------------------------------------------------------------------

# Default-Command: Raku-Version anzeigen
CMD ["raku", "-v"]
