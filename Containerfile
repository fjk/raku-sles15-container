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

# Default-Command: Raku-Version anzeigen
CMD ["raku", "-v"]
