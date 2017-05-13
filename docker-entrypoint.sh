#! /bin/bash

# Options.
DATADIR="/znc-data"

# Build modules from source.
if [ -d "${DATADIR}/modules" ]; then
  # Store current directory.
  cwd="$(pwd)"

  # Find module sources.
  modules=$(find "${DATADIR}/modules" -name "*.cpp")

  # Build modules.
  for module in $modules; do
    echo "Building module $module..."
    cd "$(dirname "$module")"
    znc-buildmod "$module"
  done

  # Go back to original directory.
  cd "$cwd"
fi

# Generate self-signed certificate if one doesn't exist
if [ ! -f "${DATADIR}/ssl/znc.pem" ]; then
  # Store current directory.
  cwd="$(pwd)"

  # Create SSL directory if one doesn't exist already
  mkdir -p "${DATADIR}/ssl"

  # Create private key, generate 5 year self-signed certificate, and concat into a pem in one shot
  # To use a signed cert, create a PEM with your key, intermediate and cert inside and put it at ${DATADIR}/ssl/znc.pem
  openssl req -subj '/CN=znc/O=ZNC/C=GB' -new -newkey rsa:2048 -sha256 -days 1825 -nodes -x509 -keyout ${DATADIR}/ssl/znc.key -out ${DATADIR}/ssl/znc.crt && \
  cat ${DATADIR}/ssl/znc.key ${DATADIR}/ssl/znc.crt > ${DATADIR}/ssl/znc.pem && \
  echo "Created self-signed certificate ${DATADIR}/ssl/znc.pem..."

  # Go back to original directory.
  cd "$cwd"
fi

# Create default config if it doesn't exist
if [ ! -f "${DATADIR}/configs/znc.conf" ]; then
  echo "Creating a default configuration..."
  mkdir -p "${DATADIR}/configs"
  cp /znc.conf.default "${DATADIR}/configs/znc.conf"
  sed -i 's#@DATADIR@#'"${DATADIR}"'#g' "${DATADIR}/configs/znc.conf"
fi

# Make sure $DATADIR is owned by znc user. This effects ownership of the
# mounted directory on the host machine too.
echo "Setting necessary permissions..."
chown -R znc:znc "$DATADIR"

# Start ZNC.
echo "Starting ZNC..."
exec sudo -u znc znc --foreground --datadir="$DATADIR" $@
