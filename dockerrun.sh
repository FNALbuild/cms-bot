function dockerrun()
{
  CONTAINER_TYPE=docker
  IMAGE_BASE="/cvmfs/cms-ib.cern.ch"
  if [ "$USE_SINGULARITY" = "true" ] ; then CONTAINER_TYPE=singularity ; fi
  case "$SCRAM_ARCH" in
    slc6_amd64_* ) IMG="cmssw/slc6:latest" ;;
    slc7_amd64_* ) IMG="cmssw/cc7:amd64" ;;
    cc8_amd64_* ) IMG="cmssw/cc8:amd64" ;;
    slc7_aarch64_* )
      CONTAINER_TYPE="qemu"
      IMG="cmssw/cc7:aarch64"
      QEMU_ARGS="$PROOTDIR/qemu-aarch64 -cpu cortex-a57"
      ;;
    cc8_aarch64_* )
      CONTAINER_TYPE="qemu"
      IMG="cmssw/cc8:aarch64"
      QEMU_ARGS="$PROOTDIR/qemu-aarch64 -cpu cortex-a57"
      ;;
    slc7_ppc64le_* )
      CONTAINER_TYPE="qemu"
      IMG="cmssw/cc7:ppc64le"
      QEMU_ARGS="$PROOTDIR/qemu-ppc64le -cpu POWER8"
      ;;
    cc8_ppc64le_* )
      CONTAINER_TYPE="qemu"
      IMG="cmssw/cc8:ppc64le"
      QEMU_ARGS="$PROOTDIR/qemu-ppc64le -cpu POWER8"
      ;;
    * )
      CONTAINER_TYPE="host"
      ;;
  esac
  case $CONTAINER_TYPE in
    docker)
      docker pull ${IMG}
      DOC_ARG="run --net=host -u $(id -u):$(id -g) --rm -t"
      DOC_ARG="${DOC_ARG} -e THISDIR=${THISDIR} -e WORKDIR=${WORKDIR} -e SCRAM_ARCH=${SCRAM_ARCH}"
      DOC_ARG="${DOC_ARG} -v ${THISDIR}:${THISDIR} -v /cvmfs:/cvmfs -v ${WORKDIR}:${WORKDIR}"
      ARGS="cd $THISDIR; for o in n s u ; do val=\"-\$o \$(ulimit -H -\$o) \${val}\"; done; ulimit \${val}; ulimit -n -s -u; $@"
      docker $DOC_ARG ${IMG} sh -c "$ARGS"
      ;;
    singularity)
      UNPACK_IMG="${IMAGE_BASE}/docker/${IMG}"
      ARGS="cd $THISDIR; for o in n s u ; do val=\"-\$o \$(ulimit -H -\$o) \${val}\"; done; ulimit \${val}; ulimit -n -s -u; $@"
      singularity -s exec -B /cvmfs -B ${THISDIR}:${THISDIR} -B ${WORKDIR}:${THISDIR} ${UNPACK_IMG} sh -c "$ARGS"
      ;;
    qemu)
      ls ${IMAGE_BASE} >/dev/null 2>&1
      ARGS="export THISDIR=${THISDIR}; export WORKDIR=${WORKDIR}; export SCRAM_ARCH=${SCRAM_ARCH}; export x=${x}; cd ${THISDIR}; $@"
      $PROOTDIR/proot -R ${IMAGE_BASE}/docker/${IMG} -b /tmp:tmp -b /build:/build -b /cvmfs:/cvmfs -w ${THISDIR} -q "${QEMU_ARGS}" sh -c "$ARGS"
      ;;
    host) eval $@;;
  esac
}
